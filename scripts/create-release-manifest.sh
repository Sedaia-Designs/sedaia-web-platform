#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  printf 'Usage: %s VERIFICATION_FILE OUTPUT_FILE\n' "$0" >&2
  exit 2
fi

verification_file="$1"
output_file="$2"

: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${CLOUD_RUN_REGION:?CLOUD_RUN_REGION is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"
: "${CLOUD_RUN_REVISION:?CLOUD_RUN_REVISION is required}"
: "${CLOUD_RUN_SERVICE_URL:?CLOUD_RUN_SERVICE_URL is required}"
: "${CLOUD_BUILD_ID:?CLOUD_BUILD_ID is required}"
: "${IMAGE_REPOSITORY:?IMAGE_REPOSITORY is required}"
: "${IMAGE_DIGEST:?IMAGE_DIGEST is required}"
: "${FINAL_TRAFFIC_FILE:?FINAL_TRAFFIC_FILE is required}"
: "${CI_REPOSITORY:?CI_REPOSITORY is required}"
: "${CI_COMMIT_SHA:?CI_COMMIT_SHA is required}"
: "${CI_PIPELINE_ID:?CI_PIPELINE_ID is required}"
: "${CI_PIPELINE_URL:?CI_PIPELINE_URL is required}"
: "${CI_JOB_ID:?CI_JOB_ID is required}"
: "${CI_JOB_URL:?CI_JOB_URL is required}"

case "${CLOUD_RUN_REVISION}" in
  ''|*[!a-z0-9-]*) printf 'Invalid Cloud Run revision: %s.\n' "${CLOUD_RUN_REVISION}" >&2; exit 1 ;;
esac
if ! printf '%s\n' "${IMAGE_DIGEST}" | grep -Eq '^sha256:[a-f0-9]{64}$'; then
  printf 'Invalid container image digest: %s.\n' "${IMAGE_DIGEST}" >&2
  exit 1
fi

jq -e '
  .readiness.passed == true and .readiness.http_status == 200 and
  .portfolio_json.passed == true and .portfolio_json.http_status == 200 and
  .portfolio_cors.passed == true
' "${verification_file}" >/dev/null
jq -e --arg revision "${CLOUD_RUN_REVISION}" '
  ([.[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${FINAL_TRAFFIC_FILE}" >/dev/null

jq --null-input \
  --slurpfile verification "${verification_file}" \
  --slurpfile traffic "${FINAL_TRAFFIC_FILE}" \
  --arg repository "${CI_REPOSITORY}" \
  --arg deployed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg run_id "${CI_PIPELINE_ID}" \
  --arg run_url "${CI_PIPELINE_URL}" \
  --arg job_id "${CI_JOB_ID}" \
  --arg job_url "${CI_JOB_URL}" \
  --arg commit_sha "${CI_COMMIT_SHA}" \
  --arg project "${GCP_PROJECT_ID}" \
  --arg region "${CLOUD_RUN_REGION}" \
  --arg service "${CLOUD_RUN_SERVICE}" \
  --arg revision "${CLOUD_RUN_REVISION}" \
  --arg service_url "${CLOUD_RUN_SERVICE_URL}" \
  --arg build_id "${CLOUD_BUILD_ID}" \
  --arg image_repository "${IMAGE_REPOSITORY}" \
  --arg image_digest "${IMAGE_DIGEST}" \
  '{schema_version: 3, status: "known-good", deployed_at: $deployed_at,
    github: {repository: $repository, workflow_run_id: $run_id, workflow_run_url: $run_url, job_id: $job_id, job_url: $job_url},
    source: {commit_sha: $commit_sha}, cloud_build: {build_id: $build_id},
    cloud_run: {project: $project, region: $region, service: $service, revision: $revision, service_url: $service_url},
    image: {repository: $image_repository, digest: $image_digest, uri: ($image_repository + "@" + $image_digest)},
    final_traffic: $traffic[0], verification: $verification[0]}' > "${output_file}"

jq -e --arg revision "${CLOUD_RUN_REVISION}" --arg digest "${IMAGE_DIGEST}" '
  .schema_version == 3 and .status == "known-good" and .image.digest == $digest and
  .verification.readiness.passed and .verification.portfolio_json.passed and .verification.portfolio_cors.passed and
  ([.final_traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${output_file}" >/dev/null
