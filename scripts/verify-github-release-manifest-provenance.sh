#!/bin/sh

set -eu

if [ "$#" -ne 3 ]; then
  printf 'Usage: %s RELEASE_RUN_ID SUPPLIED_MANIFEST VERIFIED_OUTPUT\n' "$0" >&2
  exit 2
fi

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"
: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${CLOUD_RUN_REGION:?CLOUD_RUN_REGION is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"

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
  --arg region "${CLOUD_RUN_REGION}" \
  --arg service "${CLOUD_RUN_SERVICE}" '
  .cloud_run.revision as $revision |
  .schema_version == 3 and .status == "known-good" and
  .github.repository == $repository and .github.workflow_run_id == $run_id and
  .source.commit_sha == $commit and
  (.cloud_build.build_id | type == "string" and length > 0) and
  .cloud_run.project == $project and .cloud_run.region == $region and .cloud_run.service == $service and
  (.cloud_run.revision | type == "string" and test("^[a-z0-9][a-z0-9-]{0,62}$")) and
  (.cloud_run.service_url | type == "string" and startswith("https://")) and
  (.image.repository | type == "string" and startswith($region + "-docker.pkg.dev/" + $project + "/")) and
  (.image.digest | type == "string" and test("^sha256:[a-f0-9]{64}$")) and
  .image.uri == (.image.repository + "@" + .image.digest) and
  .verification.readiness.passed == true and .verification.readiness.http_status == 200 and
  .verification.portfolio_json.passed == true and .verification.portfolio_json.http_status == 200 and
  .verification.portfolio_cors.passed == true and
  ([.final_traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${supplied_manifest}" >/dev/null

target_revision="$(jq -r '.cloud_run.revision' "${supplied_manifest}")"
target_digest="$(jq -r '.image.digest' "${supplied_manifest}")"
target_build_id="$(jq -r '.cloud_build.build_id' "${supplied_manifest}")"
revision_json="$(gcloud run revisions describe "${target_revision}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json)"
existing_revision="$(printf '%s' "${revision_json}" | jq -r '.metadata.name')"
existing_digest="$(printf '%s' "${revision_json}" | jq -r '.status.imageDigest')"
[ "${existing_revision}" = "${target_revision}" ]
[ "${existing_digest}" = "${target_digest}" ]
[ "$(printf '%s' "${revision_json}" | jq -r '.metadata.labels["build-id"]')" = "${target_build_id}" ]

cp "${supplied_manifest}" "${verified_output}"
printf 'Verified Cloud Run release manifest provenance, revision, and image digest against GitHub Actions run %s.\n' "${release_run_id}"
