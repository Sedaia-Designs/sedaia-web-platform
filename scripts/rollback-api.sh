#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s VERIFIED_RELEASE_MANIFEST\n' "$0" >&2
  exit 2
fi

manifest="$1"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${APP_ENGINE_SERVICE:?APP_ENGINE_SERVICE is required}"
: "${ROLLBACK_REASON:?ROLLBACK_REASON is required}"
: "${CI_PIPELINE_ID:?CI_PIPELINE_ID is required}"
: "${CI_PIPELINE_URL:?CI_PIPELINE_URL is required}"

jq -e --arg project "${GCP_PROJECT_ID}" --arg service "${APP_ENGINE_SERVICE}" '
  .schema_version == 2 and .status == "known-good" and
  .app_engine.project == $project and .app_engine.service == $service and
  .verification.readiness.passed and .verification.portfolio_json.passed and .verification.portfolio_cors.passed and
  .final_traffic_allocation == {(.app_engine.version): 1}
' "${manifest}" >/dev/null

target_version="$(jq -r '.app_engine.version' "${manifest}")"
service_url="$(jq -r '.app_engine.public_api_url // empty' "${manifest}")"
[ -n "${service_url}" ] || service_url="$(jq -r '.app_engine.version_url' "${manifest}")"

existing_version="$(gcloud app versions describe "${target_version}" \
  --service="${APP_ENGINE_SERVICE}" --project="${GCP_PROJECT_ID}" \
  --format='value(id)')"
[ "${existing_version}" = "${target_version}" ]

gcloud app services describe "${APP_ENGINE_SERVICE}" --project="${GCP_PROJECT_ID}" \
  --format=json > rollback-traffic-before.json
source_traffic="$(jq -c '.split.allocations' rollback-traffic-before.json)"
source_version="$(jq -r '.split.allocations | to_entries | max_by(.value).key' rollback-traffic-before.json)"
started_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

printf 'App Engine rollback target\n  project: %s\n  service: %s\n  current traffic: %s\n  target version: %s\n' \
  "${GCP_PROJECT_ID}" "${APP_ENGINE_SERVICE}" "${source_traffic}" "${target_version}"

gcloud app services set-traffic "${APP_ENGINE_SERVICE}" \
  --project="${GCP_PROJECT_ID}" --splits="${target_version}=1" --migrate --quiet

gcloud app services describe "${APP_ENGINE_SERVICE}" --project="${GCP_PROJECT_ID}" \
  --format=json > rollback-traffic-after.json
final_traffic="$(jq -c '.split.allocations' rollback-traffic-after.json)"

verification_status="failed"
if jq -e --arg version "${target_version}" '.split.allocations == {($version): 1}' rollback-traffic-after.json >/dev/null && \
   scripts/verify-api-deployment.sh "${service_url}" rollback-verification.json; then
  verification_status="passed"
else
  jq --null-input --arg checked_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{checked_at: $checked_at, passed: false, error: "Post-rollback traffic or application verification failed"}' \
    > rollback-verification.json
fi

jq --null-input --slurpfile verification rollback-verification.json \
  --arg started_at "${started_at}" --arg completed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg run_id "${CI_PIPELINE_ID}" --arg run_url "${CI_PIPELINE_URL}" \
  --arg reason "${ROLLBACK_REASON}" --arg project "${GCP_PROJECT_ID}" \
  --arg service "${APP_ENGINE_SERVICE}" --arg source_version "${source_version}" \
  --arg restored_version "${target_version}" --arg status "${verification_status}" \
  --argjson source_traffic "${source_traffic}" --argjson final_traffic "${final_traffic}" \
  '{schema_version: 2, action: "rollback", status: $status, started_at: $started_at, completed_at: $completed_at,
    initiating_workflow: {run_id: $run_id, run_url: $run_url}, reason: $reason,
    app_engine: {project: $project, service: $service, source_version: $source_version, restored_version: $restored_version},
    source_traffic_allocation: $source_traffic, final_traffic_allocation: $final_traffic,
    verification: $verification[0]}' > rollback-manifest.json

if [ "${verification_status}" != "passed" ]; then
  printf 'Rollback traffic changed, but post-rollback verification failed. Evidence was written; investigate immediately.\n' >&2
  exit 1
fi

printf 'Rollback restored App Engine version %s and passed verification.\n' "${target_version}"
