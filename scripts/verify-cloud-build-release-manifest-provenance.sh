#!/bin/sh

set -eu

if [ "$#" -ne 3 ]; then
  printf 'Usage: %s CLOUD_BUILD_ID SUPPLIED_MANIFEST VERIFIED_OUTPUT\n' "$0" >&2
  exit 2
fi

: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${CLOUD_RUN_REGION:?CLOUD_RUN_REGION is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"

cloud_build_id="$1"
supplied_manifest="$2"
verified_output="$3"
expected_trigger_id="${EXPECTED_TRIGGER_ID:-911d239d-69d9-4e1f-add6-27ef029c2469}"
expected_repository="${EXPECTED_REPOSITORY:-Sedaia-Designs/sedaia-web-platform}"

if ! printf '%s\n' "${cloud_build_id}" | grep -Eq '^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$'; then
  printf 'Cloud Build ID must be a UUID.\n' >&2
  exit 1
fi

build_json="$(gcloud builds describe "${cloud_build_id}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json)"
build_status="$(printf '%s' "${build_json}" | jq -r '.status')"
build_trigger_id="$(printf '%s' "${build_json}" | jq -r '.buildTriggerId')"
build_commit="$(printf '%s' "${build_json}" | jq -r '.substitutions.COMMIT_SHA')"
build_repository="$(printf '%s' "${build_json}" | jq -r '.substitutions.REPO_FULL_NAME')"
build_branch="$(printf '%s' "${build_json}" | jq -r '.substitutions.BRANCH_NAME')"

if [ "${build_status}" != "SUCCESS" ] || \
   [ "${build_trigger_id}" != "${expected_trigger_id}" ] || \
   [ "${build_repository}" != "${expected_repository}" ] || \
   [ "${build_branch}" != "main" ] || \
   ! printf '%s\n' "${build_commit}" | grep -Eq '^[a-f0-9]{40}$'; then
  printf 'Build %s is not a successful sedaia-api-main build from main.\n' "${cloud_build_id}" >&2
  exit 1
fi

jq -e \
  --arg repository "${expected_repository}" \
  --arg commit "${build_commit}" \
  --arg build_id "${cloud_build_id}" \
  --arg project "${GCP_PROJECT_ID}" \
  --arg region "${CLOUD_RUN_REGION}" \
  --arg service "${CLOUD_RUN_SERVICE}" '
  .cloud_run.revision as $revision |
  .schema_version == 2 and .status == "known-good" and
  .source.repository == $repository and .source.commit_sha == $commit and
  .cloud_build.build_id == $build_id and
  .cloud_run.project == $project and .cloud_run.region == $region and .cloud_run.service == $service and
  (.cloud_run.revision | type == "string" and test("^[a-z0-9][a-z0-9-]{0,62}$")) and
  (.cloud_run.candidate_url | type == "string" and startswith("https://")) and
  (.cloud_run.canonical_url | type == "string" and startswith("https://")) and
  (.image.repository | type == "string" and startswith($region + "-docker.pkg.dev/" + $project + "/")) and
  (.image.digest | type == "string" and test("^sha256:[a-f0-9]{64}$")) and
  .image.uri == (.image.repository + "@" + .image.digest) and
  .verification.candidate.readiness.passed == true and
  .verification.candidate.api_metadata.passed == true and
  .verification.candidate.portfolio_contract.passed == true and
  .verification.candidate.portfolio_cors.passed == true and
  .verification.generated_service_url.portfolio_contract.passed == true and
  .verification.canonical_url.portfolio_contract.passed == true and
  .outcome.promoted == true and .outcome.temporary_tag_removed == true and
  ([.final_traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${supplied_manifest}" >/dev/null

target_revision="$(jq -r '.cloud_run.revision' "${supplied_manifest}")"
target_digest="$(jq -r '.image.digest' "${supplied_manifest}")"
target_image_uri="$(jq -r '.image.uri' "${supplied_manifest}")"
revision_json="$(gcloud run revisions describe "${target_revision}" \
  --project="${GCP_PROJECT_ID}" --region="${CLOUD_RUN_REGION}" --format=json)"

[ "$(printf '%s' "${revision_json}" | jq -r '.metadata.name')" = "${target_revision}" ]
[ "$(printf '%s' "${revision_json}" | jq -r '.status.imageDigest')" = "${target_image_uri}" ]
[ "${target_image_uri##*@}" = "${target_digest}" ]
[ "$(printf '%s' "${revision_json}" | jq -r '.metadata.labels["build-id"]')" = "${cloud_build_id}" ]

cp "${supplied_manifest}" "${verified_output}"
printf 'Verified Cloud Run release manifest provenance, revision, and image digest against Cloud Build %s.\n' "${cloud_build_id}"
