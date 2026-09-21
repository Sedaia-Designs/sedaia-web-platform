#!/bin/sh

set -eu

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s OUTPUT_DIRECTORY\n' "$0" >&2
  exit 2
fi

output_directory="$1"

: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${CLOUD_RUN_REGION:?CLOUD_RUN_REGION is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"
: "${CLOUD_BUILD_ID:?CLOUD_BUILD_ID is required}"
: "${CI_COMMIT_SHA:?CI_COMMIT_SHA is required}"
: "${CI_REPOSITORY:?CI_REPOSITORY is required}"

image_repository="${CLOUD_RUN_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPOSITORY}/${CLOUD_RUN_SERVICE}"
mkdir -p "${output_directory}"

gcloud run services describe "${CLOUD_RUN_SERVICE}" \
  --project="${GCP_PROJECT_ID}" \
  --region="${CLOUD_RUN_REGION}" \
  --format=json > "${output_directory}/service.json"

revision="$(jq -r '.status.latestReadyRevisionName' "${output_directory}/service.json")"
service_url="$(jq -r '.status.url' "${output_directory}/service.json")"
test -n "${revision}"
test -n "${service_url}"

gcloud run revisions describe "${revision}" \
  --project="${GCP_PROJECT_ID}" \
  --region="${CLOUD_RUN_REGION}" \
  --format=json > "${output_directory}/revision.json"

image_uri="$(jq -r '.status.imageDigest' "${output_directory}/revision.json")"
image_digest="${image_uri##*@}"

jq -e \
  --arg revision "${revision}" \
  --arg build_id "${CLOUD_BUILD_ID}" \
  --arg image_repository "${image_repository}" '
    .metadata.name == $revision and
    .metadata.labels["build-id"] == $build_id and
    (.status.imageDigest | startswith($image_repository + "@sha256:")) and
    .spec.containers[0].image == .status.imageDigest and
    any(.status.conditions[]; .type == "Ready" and .status == "True")
  ' "${output_directory}/revision.json" >/dev/null

jq -e --arg revision "${revision}" '
  .status.latestCreatedRevisionName == $revision and
  .status.latestReadyRevisionName == $revision and
  ([.status.traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${output_directory}/service.json" >/dev/null

scripts/verify-api-deployment.sh "${service_url}" "${output_directory}/verification.json"
jq -c '.status.traffic' "${output_directory}/service.json" > "${output_directory}/traffic.json"

jq --null-input \
  --slurpfile verification "${output_directory}/verification.json" \
  --slurpfile traffic "${output_directory}/traffic.json" \
  --arg repository "${CI_REPOSITORY}" \
  --arg commit_sha "${CI_COMMIT_SHA}" \
  --arg build_id "${CLOUD_BUILD_ID}" \
  --arg project "${GCP_PROJECT_ID}" \
  --arg region "${CLOUD_RUN_REGION}" \
  --arg service "${CLOUD_RUN_SERVICE}" \
  --arg revision "${revision}" \
  --arg service_url "${service_url}" \
  --arg image_repository "${image_repository}" \
  --arg image_digest "${image_digest}" \
  --arg image_uri "${image_uri}" \
  --arg created_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" '
    {schema_version: 1, status: "known-good", created_at: $created_at,
     source: {repository: $repository, commit_sha: $commit_sha},
     cloud_build: {build_id: $build_id},
     cloud_run: {project: $project, region: $region, service: $service, revision: $revision, service_url: $service_url},
     image: {repository: $image_repository, digest: $image_digest, uri: $image_uri},
     final_traffic: $traffic[0], verification: $verification[0]}
  ' > "${output_directory}/release.json"

jq -e --arg revision "${revision}" --arg digest "${image_digest}" '
  .schema_version == 1 and .status == "known-good" and .image.digest == $digest and
  .verification.readiness.passed and .verification.portfolio_json.passed and .verification.portfolio_cors.passed and
  ([.final_traffic[] | select(.revisionName == $revision) | .percent] | add) == 100
' "${output_directory}/release.json" >/dev/null

printf 'Created known-good release evidence for revision %s and digest %s.\n' "${revision}" "${image_digest}"
