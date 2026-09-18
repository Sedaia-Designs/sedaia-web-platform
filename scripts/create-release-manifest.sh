#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  printf 'Usage: %s VERIFICATION_FILE OUTPUT_FILE\n' "$0" >&2
  exit 2
fi

verification_file="$1"
output_file="$2"

: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${APP_ENGINE_SERVICE:?APP_ENGINE_SERVICE is required}"
: "${APP_ENGINE_VERSION:?APP_ENGINE_VERSION is required}"
: "${APP_ENGINE_VERSION_URL:?APP_ENGINE_VERSION_URL is required}"
: "${FINAL_TRAFFIC_FILE:?FINAL_TRAFFIC_FILE is required}"
: "${CI_REPOSITORY:?CI_REPOSITORY is required}"
: "${CI_COMMIT_SHA:?CI_COMMIT_SHA is required}"
: "${CI_PIPELINE_ID:?CI_PIPELINE_ID is required}"
: "${CI_PIPELINE_URL:?CI_PIPELINE_URL is required}"
: "${CI_JOB_ID:?CI_JOB_ID is required}"
: "${CI_JOB_URL:?CI_JOB_URL is required}"

case "${APP_ENGINE_VERSION}" in
  ''|*[!a-z0-9-]*) printf 'Invalid App Engine version: %s.\n' "${APP_ENGINE_VERSION}" >&2; exit 1 ;;
esac

jq -e '
  .readiness.passed == true and .readiness.http_status == 200 and
  .portfolio_json.passed == true and .portfolio_json.http_status == 200 and
  .portfolio_cors.passed == true
' "${verification_file}" >/dev/null
jq -e --arg version "${APP_ENGINE_VERSION}" '. == {($version): 1}' "${FINAL_TRAFFIC_FILE}" >/dev/null

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
  --arg service "${APP_ENGINE_SERVICE}" \
  --arg version "${APP_ENGINE_VERSION}" \
  --arg version_url "${APP_ENGINE_VERSION_URL}" \
  --arg public_api_url "${PUBLIC_API_URL:-}" \
  '{schema_version: 2, status: "known-good", deployed_at: $deployed_at,
    github: {repository: $repository, workflow_run_id: $run_id, workflow_run_url: $run_url, job_id: $job_id, job_url: $job_url},
    source: {commit_sha: $commit_sha},
    app_engine: {project: $project, service: $service, version: $version, version_url: $version_url, public_api_url: $public_api_url},
    final_traffic_allocation: $traffic[0], verification: $verification[0]}' > "${output_file}"

jq -e --arg version "${APP_ENGINE_VERSION}" '
  .schema_version == 2 and .status == "known-good" and
  .verification.readiness.passed and .verification.portfolio_json.passed and .verification.portfolio_cors.passed and
  .final_traffic_allocation == {($version): 1}
' "${output_file}" >/dev/null
