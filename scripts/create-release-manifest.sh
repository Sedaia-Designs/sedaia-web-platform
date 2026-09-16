#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  printf 'Usage: %s VERIFICATION_FILE OUTPUT_FILE\n' "$0" >&2
  exit 2
fi

verification_file="$1"
output_file="$2"

: "${GCP_PROJECT_ID:?GCP_PROJECT_ID is required}"
: "${GCP_REGION:?GCP_REGION is required}"
: "${ARTIFACT_REGISTRY_REPO:?ARTIFACT_REGISTRY_REPO is required}"
: "${CLOUD_RUN_SERVICE:?CLOUD_RUN_SERVICE is required}"
: "${CI_COMMIT_SHA:?CI_COMMIT_SHA is required}"
: "${CI_PIPELINE_ID:?CI_PIPELINE_ID is required}"
: "${CI_PIPELINE_URL:?CI_PIPELINE_URL is required}"
: "${CI_JOB_ID:?CI_JOB_ID is required}"
: "${CI_JOB_URL:?CI_JOB_URL is required}"
: "${SERVICE_URL:?SERVICE_URL is required}"
: "${DEPLOYED_REVISION:?DEPLOYED_REVISION is required}"
: "${IMAGE_DIGEST:?IMAGE_DIGEST is required}"
: "${FINAL_TRAFFIC_REVISION:?FINAL_TRAFFIC_REVISION is required}"

case "${IMAGE_DIGEST}" in
  sha256:*) ;;
  *) printf 'Expected a sha256 image digest, received %s.\n' "${IMAGE_DIGEST}" >&2; exit 1 ;;
esac

image_name="${GCP_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${CLOUD_RUN_SERVICE}"
public_api_url="${PUBLIC_API_URL:-https://api.sedaia-designs.org}"

jq --null-input \
  --slurpfile verification "${verification_file}" \
  --arg schema_version "1" \
  --arg deployed_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg pipeline_id "${CI_PIPELINE_ID}" \
  --arg pipeline_url "${CI_PIPELINE_URL}" \
  --arg job_id "${CI_JOB_ID}" \
  --arg job_url "${CI_JOB_URL}" \
  --arg commit_sha "${CI_COMMIT_SHA}" \
  --arg project "${GCP_PROJECT_ID}" \
  --arg region "${GCP_REGION}" \
  --arg repository "${ARTIFACT_REGISTRY_REPO}" \
  --arg image_uri "${image_name}" \
  --arg image_tag "${CI_COMMIT_SHA}" \
  --arg image_digest "${IMAGE_DIGEST}" \
  --arg digest_reference "${image_name}@${IMAGE_DIGEST}" \
  --arg service "${CLOUD_RUN_SERVICE}" \
  --arg revision "${DEPLOYED_REVISION}" \
  --arg service_url "${SERVICE_URL}" \
  --arg public_api_url "${public_api_url}" \
  --arg traffic_revision "${FINAL_TRAFFIC_REVISION}" \
  '{
    schema_version: ($schema_version | tonumber),
    status: "known-good",
    deployed_at: $deployed_at,
    gitlab: {pipeline_id: $pipeline_id, pipeline_url: $pipeline_url, job_id: $job_id, job_url: $job_url},
    source: {commit_sha: $commit_sha},
    artifact: {project: $project, region: $region, repository: $repository, image_uri: $image_uri, commit_tag: $image_tag, digest: $image_digest, digest_reference: $digest_reference},
    cloud_run: {service: $service, revision: $revision, service_url: $service_url, public_api_url: $public_api_url},
    verification: $verification[0],
    production_traffic: {revision: $traffic_revision, percent: 100}
  }' > "${output_file}"

jq -e '.verification.readiness.passed and .verification.portfolio_json.passed and .verification.portfolio_cors.passed and (.cloud_run.revision == .production_traffic.revision)' "${output_file}" >/dev/null
