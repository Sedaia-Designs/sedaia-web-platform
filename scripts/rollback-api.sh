#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s VERIFIED_RELEASE_MANIFEST\n' "$0" >&2
  exit 2
fi

manifest="$1"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${CLOUD_RUN_REGION:?CLOUD_RUN_REGION is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"
: "${ROLLBACK_REASON:?ROLLBACK_REASON is required}"
: "${CI_PIPELINE_ID:?CI_PIPELINE_ID is required}"
: "${CI_PIPELINE_URL:?CI_PIPELINE_URL is required}"

jq -e --arg project "${GCP_PROJECT_ID}" --arg region "${CLOUD_RUN_REGION}" --arg service "${CLOUD_RUN_SERVICE}" '
  .cloud_run.revision as $revision |
  .schema_version == 1 and .status == "known-good" and
  .cloud_run.project == $project and .cloud_run.region == $region and .cloud_run.service == $service and
  .image.uri == (.image.repository + "@" + .image.digest) and
  .verification.readiness.passed and .verification.portfolio_json.passed and .verification.portfolio_cors.passed and
  ([.final_traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${manifest}" >/dev/null

target_revision="$(jq -r '.cloud_run.revision' "${manifest}")"
target_digest="$(jq -r '.image.digest' "${manifest}")"
target_image_uri="$(jq -r '.image.uri' "${manifest}")"
service_url="$(jq -r '.cloud_run.service_url' "${manifest}")"

revision_json="$(gcloud run revisions describe "${target_revision}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json)"
[ "$(printf '%s' "${revision_json}" | jq -r '.metadata.name')" = "${target_revision}" ]
[ "$(printf '%s' "${revision_json}" | jq -r '.status.imageDigest')" = "${target_image_uri}" ]

gcloud run services describe "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" \
  --format=json > rollback-service-before.json
source_revision="$(jq -r '.status.traffic | max_by(.percent).revisionName' rollback-service-before.json)"
source_image_uri="$(gcloud run revisions describe "${source_revision}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format='value(status.imageDigest)')"
source_digest="${source_image_uri##*@}"
started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

printf 'Cloud Run rollback target\n  project: %s\n  region: %s\n  service: %s\n  current revision: %s\n  target revision: %s\n  target digest: %s\n' \
  "${GCP_PROJECT_ID}" "${CLOUD_RUN_REGION}" "${CLOUD_RUN_SERVICE}" \
  "${source_revision}" "${target_revision}" "${target_digest}"

gcloud run services update-traffic "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" \
  --to-revisions="${target_revision}=100" --quiet

gcloud run services describe "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" \
  --format=json > rollback-service-after.json

verification_status="failed"
if jq -e --arg revision "${target_revision}" '
     ([.status.traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
   ' rollback-service-after.json >/dev/null && \
   scripts/verify-api-deployment.sh "${service_url}" rollback-verification.json; then
  verification_status="passed"
else
  jq --null-input --arg checked_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{checked_at: $checked_at, passed: false, error: "Post-rollback traffic or application verification failed"}' \
    > rollback-verification.json
fi

jq --null-input --slurpfile verification rollback-verification.json \
  --slurpfile before rollback-service-before.json --slurpfile after rollback-service-after.json \
  --arg started_at "${started_at}" --arg completed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg run_id "${CI_PIPELINE_ID}" --arg run_url "${CI_PIPELINE_URL}" \
  --arg reason "${ROLLBACK_REASON}" --arg project "${GCP_PROJECT_ID}" \
  --arg region "${CLOUD_RUN_REGION}" --arg service "${CLOUD_RUN_SERVICE}" \
  --arg source_revision "${source_revision}" --arg source_digest "${source_digest}" \
  --arg restored_revision "${target_revision}" --arg restored_digest "${target_digest}" \
  --arg status "${verification_status}" \
  '{schema_version: 3, action: "rollback", status: $status, started_at: $started_at, completed_at: $completed_at,
    initiating_workflow: {run_id: $run_id, run_url: $run_url}, reason: $reason,
    cloud_run: {project: $project, region: $region, service: $service,
      source_revision: $source_revision, restored_revision: $restored_revision},
    images: {source_digest: $source_digest, restored_digest: $restored_digest},
    source_traffic: $before[0].status.traffic, final_traffic: $after[0].status.traffic,
    verification: $verification[0]}' > rollback-manifest.json

if [ "${verification_status}" != "passed" ]; then
  printf 'Rollback traffic changed, but post-rollback verification failed. Evidence was written; investigate immediately.\n' >&2
  exit 1
fi

printf 'Rollback restored Cloud Run revision %s at image digest %s and passed verification.\n' \
  "${target_revision}" "${target_digest}"
