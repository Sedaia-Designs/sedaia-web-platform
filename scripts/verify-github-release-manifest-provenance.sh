#!/bin/sh

set -eu

if [ "$#" -ne 3 ]; then
  printf 'Usage: %s RELEASE_RUN_ID SUPPLIED_MANIFEST VERIFIED_OUTPUT\n' "$0" >&2
  exit 2
fi

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${APP_ENGINE_SERVICE:?APP_ENGINE_SERVICE is required}"

release_run_id="$1"
supplied_manifest="$2"
verified_output="$3"
expected_ref="${EXPECTED_DEPLOY_REF:-refs/heads/main}"

case "${release_run_id}" in
  ''|*[!0-9]*) printf 'Release workflow run ID must be numeric.\n' >&2; exit 1 ;;
esac

run_json="$(gh api "repos/${GITHUB_REPOSITORY}/actions/runs/${release_run_id}")"
run_repository="$(printf '%s' "${run_json}" | jq -r '.repository.full_name')"
run_event="$(printf '%s' "${run_json}" | jq -r '.event')"
run_status="$(printf '%s' "${run_json}" | jq -r '.status')"
run_conclusion="$(printf '%s' "${run_json}" | jq -r '.conclusion')"
run_commit="$(printf '%s' "${run_json}" | jq -r '.head_sha')"
run_workflow_path="$(printf '%s' "${run_json}" | jq -r '.path')"
run_ref="$(printf '%s' "${run_json}" | jq -r '.head_branch | "refs/heads/" + .')"

if [ "${run_repository}" != "${GITHUB_REPOSITORY}" ] || \
   [ "${run_event}" != "workflow_dispatch" ] || \
   [ "${run_status}" != "completed" ] || \
   [ "${run_conclusion}" != "success" ] || \
   [ "${run_workflow_path}" != ".github/workflows/deploy-api.yml" ] || \
   [ "${run_ref}" != "${expected_ref}" ]; then
  printf 'Run %s is not a successful manual API deployment from %s for %s.\n' \
    "${release_run_id}" "${expected_ref}" "${GITHUB_REPOSITORY}" >&2
  exit 1
fi

jq -e \
  --arg repository "${GITHUB_REPOSITORY}" \
  --arg run_id "${release_run_id}" \
  --arg commit "${run_commit}" \
  --arg project "${GCP_PROJECT_ID}" \
  --arg service "${APP_ENGINE_SERVICE}" '
  .schema_version == 2 and .status == "known-good" and
  .github.repository == $repository and .github.workflow_run_id == $run_id and
  .source.commit_sha == $commit and
  .app_engine.project == $project and .app_engine.service == $service and
  (.app_engine.version | type == "string" and test("^[a-z0-9][a-z0-9-]{0,62}$")) and
  (.app_engine.version_url | type == "string" and startswith("https://")) and
  .verification.readiness.passed == true and .verification.readiness.http_status == 200 and
  .verification.portfolio_json.passed == true and .verification.portfolio_json.http_status == 200 and
  .verification.portfolio_cors.passed == true and
  .final_traffic_allocation == {(.app_engine.version): 1}
' "${supplied_manifest}" >/dev/null

target_version="$(jq -r '.app_engine.version' "${supplied_manifest}")"
existing_version="$(gcloud app versions describe "${target_version}" \
  --service="${APP_ENGINE_SERVICE}" --project="${GCP_PROJECT_ID}" \
  --format='value(id)')"
[ "${existing_version}" = "${target_version}" ]

cp "${supplied_manifest}" "${verified_output}"
printf 'Verified App Engine release manifest provenance against GitHub Actions run %s.\n' "${release_run_id}"
