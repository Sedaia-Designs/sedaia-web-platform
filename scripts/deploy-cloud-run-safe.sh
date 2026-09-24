#!/usr/bin/env bash

set -Eeuo pipefail

if [[ "$#" -ne 1 ]]; then
  printf 'Usage: %s OUTPUT_DIRECTORY\n' "$0" >&2
  exit 2
fi

: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${CLOUD_RUN_REGION:?CLOUD_RUN_REGION is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"
: "${RUNTIME_SERVICE_ACCOUNT:?RUNTIME_SERVICE_ACCOUNT is required}"
: "${ARTIFACT_REGISTRY_REPOSITORY:?ARTIFACT_REGISTRY_REPOSITORY is required}"
: "${CLOUD_BUILD_ID:?CLOUD_BUILD_ID is required}"
: "${CI_COMMIT_SHA:?CI_COMMIT_SHA is required}"
: "${CI_REPOSITORY:?CI_REPOSITORY is required}"
: "${RELEASE_EVIDENCE_BUCKET:?RELEASE_EVIDENCE_BUCKET is required}"
: "${DEPLOYMENT_LOCK_BUCKET:?DEPLOYMENT_LOCK_BUCKET is required}"
: "${CANONICAL_API_URL:?CANONICAL_API_URL is required}"

if [[ ! "${CLOUD_BUILD_ID}" =~ ^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$ ]]; then
  printf 'CLOUD_BUILD_ID must be a lowercase UUID.\n' >&2
  exit 2
fi
if [[ ! "${CI_COMMIT_SHA}" =~ ^[a-f0-9]{40}$ ]]; then
  printf 'CI_COMMIT_SHA must be a full lowercase Git commit SHA.\n' >&2
  exit 2
fi
if [[ ! "${CI_REPOSITORY}" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
  printf 'CI_REPOSITORY must be an owner/repository name.\n' >&2
  exit 2
fi
if [[ ! "${CANONICAL_API_URL}" =~ ^https://[^/]+/?$ ]]; then
  printf 'CANONICAL_API_URL must be an HTTPS origin.\n' >&2
  exit 2
fi

readonly output_directory="$1"
readonly image_repository="${CLOUD_RUN_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPOSITORY}/${CLOUD_RUN_SERVICE}"
readonly image_tag="${image_repository}:${CLOUD_BUILD_ID}"
readonly traffic_tag="b-${CLOUD_BUILD_ID//-/}"
readonly lock_directory="${output_directory}/lock"
readonly evidence_uri="gs://${RELEASE_EVIDENCE_BUCKET}/${CLOUD_BUILD_ID}/"
readonly started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
readonly deployment_verifier="${DEPLOYMENT_VERIFIER:-scripts/verify-api-deployment.sh}"
readonly pre_deploy_verifier="${PRE_DEPLOY_VERIFIER:-scripts/verify-api-pre-deploy.sh}"

candidate_revision=""
candidate_url=""
image_uri=""
image_digest=""
stage="capture-pre-deploy"
promoted=false
rollback_attempted=false
rollback_passed=false
tag_removed=false
lock_acquired=false
finalizing=false

mkdir -p "${output_directory}"

record_failure() {
  local exit_code="$1"
  jq --null-input \
    --arg stage "${stage}" \
    --argjson exit_code "${exit_code}" \
    --arg recorded_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{stage: $stage, exit_code: $exit_code, recorded_at: $recorded_at}' \
    > "${output_directory}/failure.json"
}

traffic_arguments() {
  jq -r '
    [.status.traffic[] | select((.percent // 0) > 0) | (.revisionName + "=" + (.percent | tostring))]
    | join(",")
  ' "$1"
}

capture_final_state() {
  gcloud run services describe "${CLOUD_RUN_SERVICE}" \
    --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json \
    > "${output_directory}/final-service.json" || true
}

remove_candidate_tag() {
  if [[ -n "${candidate_revision}" ]]; then
    if gcloud run services update-traffic "${CLOUD_RUN_SERVICE}" \
      --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" \
      --remove-tags="${traffic_tag}" --quiet; then
      tag_removed=true
    fi
  fi
}

restore_previous_traffic() {
  local allocation
  allocation="$(traffic_arguments "${output_directory}/pre-deploy-service.json")"
  [[ -n "${allocation}" ]]
  rollback_attempted=true
  gcloud run services update-traffic "${CLOUD_RUN_SERVICE}" \
    --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" \
    --to-revisions="${allocation}" --quiet
  gcloud run services describe "${CLOUD_RUN_SERVICE}" \
    --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json \
    > "${output_directory}/recovery-service.json"
  jq -e --slurpfile before "${output_directory}/pre-deploy-service.json" '
    def allocation: [.status.traffic[] | select((.percent // 0) > 0) | {revisionName, percent}] | sort_by(.revisionName);
    allocation == ($before[0] | allocation)
  ' "${output_directory}/recovery-service.json" >/dev/null
  "${deployment_verifier}" \
    "$(jq -r '.status.url' "${output_directory}/recovery-service.json")" \
    "${output_directory}/recovery-verification.json"
  "${deployment_verifier}" "${CANONICAL_API_URL%/}" \
    "${output_directory}/recovery-canonical-verification.json"
  rollback_passed=true
}

write_manifest() {
  local status="$1"
  local evidence_file
  for evidence_file in pre-deploy-service.json pre-deploy-generated-verification.json \
    pre-deploy-canonical-verification.json candidate-verification.json promotion-generated-verification.json \
    promotion-canonical-verification.json final-service.json; do
    if [[ ! -f "${output_directory}/${evidence_file}" ]]; then
      printf '{}\n' > "${output_directory}/${evidence_file}"
    fi
  done
  jq --null-input \
    --slurpfile before "${output_directory}/pre-deploy-service.json" \
    --slurpfile final "${output_directory}/final-service.json" \
    --slurpfile pre_deploy_generated_verification "${output_directory}/pre-deploy-generated-verification.json" \
    --slurpfile pre_deploy_canonical_verification "${output_directory}/pre-deploy-canonical-verification.json" \
    --slurpfile candidate_verification "${output_directory}/candidate-verification.json" \
    --slurpfile generated_verification "${output_directory}/promotion-generated-verification.json" \
    --slurpfile canonical_verification "${output_directory}/promotion-canonical-verification.json" \
    --arg status "${status}" --arg started_at "${started_at}" \
    --arg completed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg repository "${CI_REPOSITORY}" --arg commit_sha "${CI_COMMIT_SHA}" \
    --arg build_id "${CLOUD_BUILD_ID}" --arg project "${GCP_PROJECT_ID}" \
    --arg region "${CLOUD_RUN_REGION}" --arg service "${CLOUD_RUN_SERVICE}" \
    --arg revision "${candidate_revision}" --arg candidate_url "${candidate_url}" \
    --arg canonical_url "${CANONICAL_API_URL%/}" --arg image_repository "${image_repository}" \
    --arg image_digest "${image_digest}" --arg image_uri "${image_uri}" \
    --argjson promoted "${promoted}" --argjson rollback_attempted "${rollback_attempted}" \
    --argjson rollback_passed "${rollback_passed}" --argjson tag_removed "${tag_removed}" '
      {schema_version: 2, status: $status, started_at: $started_at, completed_at: $completed_at,
       source: {repository: $repository, commit_sha: $commit_sha}, cloud_build: {build_id: $build_id},
       cloud_run: {project: $project, region: $region, service: $service, revision: $revision,
         candidate_url: $candidate_url, canonical_url: $canonical_url},
       image: {repository: $image_repository, digest: $image_digest, uri: $image_uri},
       pre_deploy_traffic: $before[0].status.traffic,
       final_traffic: ($final[0].status.traffic // []),
       verification: {pre_deploy_generated_service_url: $pre_deploy_generated_verification[0],
          pre_deploy_canonical_url: $pre_deploy_canonical_verification[0], candidate: $candidate_verification[0],
         generated_service_url: $generated_verification[0], canonical_url: $canonical_verification[0]},
       outcome: {promoted: $promoted, rollback_attempted: $rollback_attempted,
         rollback_passed: $rollback_passed, temporary_tag_removed: $tag_removed}}
    ' > "${output_directory}/release.json"
}

finalize() {
  local original_exit="$1"
  local deployment_status="failed"
  [[ "${finalizing}" == false ]] || return
  finalizing=true
  trap - EXIT
  set +e
  if [[ "${original_exit}" -ne 0 ]]; then
    record_failure "${original_exit}"
    if [[ "${promoted}" == true && "${rollback_attempted}" == false ]]; then
      stage="rollback"
      restore_previous_traffic
      rollback_exit=$?
      if [[ "${rollback_exit}" -ne 0 ]]; then
        rollback_passed=false
      fi
    fi
  fi
  remove_candidate_tag
  capture_final_state
  if [[ "${original_exit}" -eq 0 && "${tag_removed}" == true ]] && \
    jq -e --arg revision "${candidate_revision}" '
      ([.status.traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
    ' "${output_directory}/final-service.json" >/dev/null; then
    deployment_status="known-good"
  fi
  write_manifest "${deployment_status}"
  gcloud storage cp "${output_directory}"/*.json "${evidence_uri}"
  evidence_exit=$?
  if [[ "${lock_acquired}" == true ]]; then
    scripts/cloud-run-deployment-lock.sh release "${lock_directory}"
    lock_exit=$?
  else
    lock_exit=0
  fi
  set -e
  if [[ "${original_exit}" -ne 0 ]]; then
    exit "${original_exit}"
  fi
  if [[ "${evidence_exit}" -ne 0 || "${lock_exit}" -ne 0 || "${tag_removed}" != true ]]; then
    printf 'Deployment succeeded, but evidence upload, tag cleanup, or lock release failed.\n' >&2
    exit 1
  fi
}

trap 'finalize $?' EXIT

stage="acquire-lock"
export DEPLOYMENT_LOCK_OWNER="cloud-build:${CLOUD_BUILD_ID}"
scripts/cloud-run-deployment-lock.sh acquire "${lock_directory}"
lock_acquired=true

stage="capture-pre-deploy"
gcloud run services describe "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json \
  > "${output_directory}/pre-deploy-service.json"
previous_revision="$(jq -r '.status.traffic | max_by(.percent).revisionName' "${output_directory}/pre-deploy-service.json")"
gcloud run revisions describe "${previous_revision}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json \
  > "${output_directory}/pre-deploy-revision.json"
previous_image_digest="$(jq -r '.status.imageDigest | split("@") | last' "${output_directory}/pre-deploy-revision.json")"
"${pre_deploy_verifier}" "$(jq -r '.status.url' "${output_directory}/pre-deploy-service.json")" \
  "${previous_revision}" "${previous_image_digest}" \
  "${output_directory}/pre-deploy-generated-verification.json"
"${pre_deploy_verifier}" "${CANONICAL_API_URL%/}" \
  "${previous_revision}" "${previous_image_digest}" \
  "${output_directory}/pre-deploy-canonical-verification.json"

stage="deploy-zero-traffic-candidate"
gcloud run deploy "${CLOUD_RUN_SERVICE}" --image="${image_tag}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --platform=managed \
  --service-account="${RUNTIME_SERVICE_ACCOUNT}" --allow-unauthenticated --ingress=all --port=8080 \
  --min-instances=0 --max-instances=3 --memory=512Mi --cpu=1 --concurrency=40 --timeout=30s \
  --startup-probe=httpGet.path=/health/ready,httpGet.port=8080,initialDelaySeconds=0,timeoutSeconds=2,periodSeconds=5,failureThreshold=12 \
  --liveness-probe=httpGet.path=/health/live,httpGet.port=8080,initialDelaySeconds=10,timeoutSeconds=2,periodSeconds=30,failureThreshold=3 \
  --labels="managed-by=cloud-build,build-id=${CLOUD_BUILD_ID}" --no-traffic --tag="${traffic_tag}" --quiet

stage="resolve-and-validate-candidate"
gcloud run revisions list --service="${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" \
  --filter="metadata.labels.build-id=${CLOUD_BUILD_ID}" --sort-by=~metadata.creationTimestamp \
  --limit=2 --format=json > "${output_directory}/candidate-revisions.json"
candidate_revision="$(jq -r 'if length == 1 then .[0].metadata.name else empty end' "${output_directory}/candidate-revisions.json")"
[[ -n "${candidate_revision}" ]]
gcloud run revisions describe "${candidate_revision}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json \
  > "${output_directory}/candidate-revision.json"
gcloud run services describe "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json \
  > "${output_directory}/candidate-service.json"
candidate_url="$(jq -r --arg tag "${traffic_tag}" '.status.traffic[] | select(.tag == $tag) | .url' "${output_directory}/candidate-service.json")"
image_uri="$(jq -r '.status.imageDigest' "${output_directory}/candidate-revision.json")"
image_digest="${image_uri##*@}"
jq -e --arg revision "${candidate_revision}" --arg build_id "${CLOUD_BUILD_ID}" \
  --arg image_repository "${image_repository}" --arg runtime "${RUNTIME_SERVICE_ACCOUNT}" '
    .metadata.name == $revision and .metadata.labels["build-id"] == $build_id and
    (.status.imageDigest | startswith($image_repository + "@sha256:")) and
    .spec.containers[0].image == .status.imageDigest and .spec.serviceAccountName == $runtime and
    .spec.containerConcurrency == 40 and .spec.timeoutSeconds == 30 and
    (.spec.containers[0].resources.limits.cpu == "1" or .spec.containers[0].resources.limits.cpu == "1000m") and
    .spec.containers[0].resources.limits.memory == "512Mi" and
    .spec.containers[0].startupProbe.httpGet.path == "/health/ready" and
    .spec.containers[0].livenessProbe.httpGet.path == "/health/live" and
    any(.status.conditions[]; .type == "Ready" and .status == "True")
  ' "${output_directory}/candidate-revision.json" >/dev/null
jq -e '
  .spec.template.metadata.annotations["autoscaling.knative.dev/maxScale"] == "3" and
  ((.spec.template.metadata.annotations["autoscaling.knative.dev/minScale"] // "0") == "0")
' "${output_directory}/candidate-service.json" >/dev/null
jq -e --arg revision "${candidate_revision}" --arg tag "${traffic_tag}" '
    ([.status.traffic[] | select(.revisionName == $revision) | .percent // 0] | add // 0) == 0 and
    ([.status.traffic[] | select(.revisionName == $revision and .tag == $tag and (.url | startswith("https://")))] | length) == 1
  ' "${output_directory}/candidate-service.json" >/dev/null

stage="verify-candidate"
"${deployment_verifier}" "${candidate_url}" "${output_directory}/candidate-verification.json"

stage="promote-named-revision"
gcloud run services update-traffic "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" \
  --to-revisions="${candidate_revision}=100" --quiet
promoted=true
gcloud run services describe "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json \
  > "${output_directory}/promotion-service.json"
jq -e --arg revision "${candidate_revision}" '
  ([.status.traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${output_directory}/promotion-service.json" >/dev/null

stage="verify-promoted-generated-url"
"${deployment_verifier}" "$(jq -r '.status.url' "${output_directory}/promotion-service.json")" \
  "${output_directory}/promotion-generated-verification.json"
stage="verify-promoted-canonical-url"
"${deployment_verifier}" "${CANONICAL_API_URL%/}" \
  "${output_directory}/promotion-canonical-verification.json"

stage="finalize-evidence"
