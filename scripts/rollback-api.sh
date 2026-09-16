#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s VERIFIED_RELEASE_MANIFEST\n' "$0" >&2
  exit 2
fi

manifest="$1"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${GCP_REGION:?GCP_REGION is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"
: "${CLOUD_RUN_SERVICE_ACCOUNT:?CLOUD_RUN_SERVICE_ACCOUNT is required}"
: "${ROLLBACK_REASON:?ROLLBACK_REASON is required}"
: "${CI_PIPELINE_ID:?CI_PIPELINE_ID is required}"
: "${CI_PIPELINE_URL:?CI_PIPELINE_URL is required}"

jq -e '
  .status == "known-good" and
  .verification.readiness.passed and
  .verification.portfolio_json.passed and
  .verification.portfolio_cors.passed and
  (.artifact.digest | startswith("sha256:"))
' "${manifest}" >/dev/null

target_project="$(jq -r '.artifact.project' "${manifest}")"
target_region="$(jq -r '.artifact.region' "${manifest}")"
target_service="$(jq -r '.cloud_run.service' "${manifest}")"
target_revision="$(jq -r '.cloud_run.revision' "${manifest}")"
target_digest="$(jq -r '.artifact.digest' "${manifest}")"
target_image="$(jq -r '.artifact.digest_reference' "${manifest}")"

if [ "${target_project}" != "${GCP_PROJECT_ID}" ] || [ "${target_region}" != "${GCP_REGION}" ] || [ "${target_service}" != "${CLOUD_RUN_SERVICE}" ]; then
  printf 'Manifest target does not match configured production target.\n' >&2
  exit 1
fi

source_revision="$(gcloud run services describe "${CLOUD_RUN_SERVICE}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --format='value(status.traffic[percent=100].revisionName)')"
started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

printf 'Rollback target\n  project: %s\n  region: %s\n  service: %s\n  current revision: %s\n  target revision: %s\n  target digest: %s\n' \
  "${GCP_PROJECT_ID}" "${GCP_REGION}" "${CLOUD_RUN_SERVICE}" "${source_revision}" "${target_revision}" "${target_digest}"

existing_digest="$(gcloud run revisions describe "${target_revision}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --format='value(status.imageDigest)' 2>/dev/null || true)"
if [ "${existing_digest}" = "${target_digest}" ]; then
  gcloud run services update-traffic "${CLOUD_RUN_SERVICE}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --to-revisions="${target_revision}=100" --quiet
  restored_revision="${target_revision}"
else
  printf 'Recorded revision is unavailable; redeploying immutable image %s.\n' "${target_image}"
  gcloud run deploy "${CLOUD_RUN_SERVICE}" \
    --image="${target_image}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" \
    --port=8080 --service-account="${CLOUD_RUN_SERVICE_ACCOUNT}" --ingress=all \
    --allow-unauthenticated --min-instances=0 --max-instances=3 --memory=512Mi \
    --cpu=1 --concurrency=40 --timeout=30s \
    --update-labels="source-commit=$(jq -r '.source.commit_sha' "${manifest}"),rollback-pipeline=${CI_PIPELINE_ID}" --quiet
  restored_revision="$(gcloud run services describe "${CLOUD_RUN_SERVICE}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --format='value(status.latestReadyRevisionName)')"
  gcloud run services update-traffic "${CLOUD_RUN_SERVICE}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --to-revisions="${restored_revision}=100" --quiet
fi

service_url="$(gcloud run services describe "${CLOUD_RUN_SERVICE}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --format='value(status.url)')"
if ! scripts/verify-api-deployment.sh "${service_url}" rollback-verification.json; then
  printf 'Rollback verification failed. Traffic was not switched forward automatically. Inspect the restored revision and either repair it or start another manual rollback with a different known-good manifest.\n' >&2
  exit 1
fi
final_revision="$(gcloud run services describe "${CLOUD_RUN_SERVICE}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --format='value(status.traffic[percent=100].revisionName)')"
final_digest="$(gcloud run revisions describe "${final_revision}" --project="${GCP_PROJECT_ID}" --region="${GCP_REGION}" --format='value(status.imageDigest)')"

if [ "${final_digest}" != "${target_digest}" ]; then
  printf 'Rollback verification passed, but final digest does not match the manifest. Inspect traffic manually; no automatic forward switch was attempted.\n' >&2
  exit 1
fi

jq --null-input --slurpfile verification rollback-verification.json \
  --arg started_at "${started_at}" --arg completed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg pipeline_id "${CI_PIPELINE_ID}" --arg pipeline_url "${CI_PIPELINE_URL}" \
  --arg reason "${ROLLBACK_REASON}" --arg source_revision "${source_revision}" \
  --arg restored_revision "${restored_revision}" --arg final_revision "${final_revision}" \
  --arg digest "${final_digest}" \
  '{schema_version: 1, action: "rollback", started_at: $started_at, completed_at: $completed_at,
    initiating_pipeline: {id: $pipeline_id, url: $pipeline_url}, reason: $reason,
    source_revision: $source_revision, restored_revision: $restored_revision, restored_digest: $digest,
    verification: $verification[0], final_traffic: {revision: $final_revision, percent: 100}}' > rollback-manifest.json
