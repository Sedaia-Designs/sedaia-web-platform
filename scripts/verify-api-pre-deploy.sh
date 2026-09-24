#!/bin/sh

set -eu

if [ "$#" -ne 4 ]; then
  printf 'Usage: %s SERVICE_URL REVISION IMAGE_DIGEST RESULT_FILE\n' "$0" >&2
  exit 2
fi

readonly base_url="${1%/}"
readonly revision="$2"
readonly image_digest="$3"
readonly result_file="$4"
readonly legacy_revision="${LEGACY_PRE_DEPLOY_REVISION:-sedaia-api-00006-xb4}"
readonly legacy_digest="${LEGACY_PRE_DEPLOY_DIGEST:-sha256:13f83e2eb79fc89f2e7ad2a54d694a3b80bdd57107783fca33b126bac2c51598}"
readonly response_directory="$(mktemp -d)"

rm -f "${result_file}"

cleanup() {
  rm -rf "${response_directory}"
}

trap cleanup EXIT INT TERM

request_json() {
  path="$1"
  body_file="$2"
  headers_file="$3"
  curl --silent --show-error --dump-header "${headers_file}" --output "${body_file}" \
    --write-out '%{http_code}' --connect-timeout 3 --max-time 10 "${base_url}${path}"
}

is_json_response() {
  headers_file="$1"
  awk 'tolower($0) ~ /^content-type:[[:space:]]*application\/json([[:space:]]*;|\r?$)/ { found = 1 } END { exit !found }' "${headers_file}"
}

readiness_body="${response_directory}/readiness.json"
readiness_headers="${response_directory}/readiness-headers.txt"
readiness_status="$(request_json '/health/ready' "${readiness_body}" "${readiness_headers}")"
if [ "${readiness_status}" != "200" ] ||
  ! is_json_response "${readiness_headers}" ||
  ! jq --exit-status 'type == "object" and length == 0' "${readiness_body}" >/dev/null; then
  printf 'Pre-deploy readiness verification failed for %s (HTTP %s).\n' "${revision}" "${readiness_status}" >&2
  exit 1
fi

metadata_path='/v1'
metadata_body="${response_directory}/metadata.json"
metadata_headers="${response_directory}/metadata-headers.txt"
metadata_status="$(request_json "${metadata_path}" "${metadata_body}" "${metadata_headers}")"

if [ "${metadata_status}" = "404" ]; then
  if [ "${revision}" != "${legacy_revision}" ] || [ "${image_digest}" != "${legacy_digest}" ]; then
    printf 'Canonical pre-deploy metadata failed for unapproved revision %s (HTTP %s).\n' "${revision}" "${metadata_status}" >&2
    exit 1
  fi
  metadata_path='/v1/'
  metadata_status="$(request_json "${metadata_path}" "${metadata_body}" "${metadata_headers}")"
fi

if [ "${metadata_status}" != "200" ] || ! is_json_response "${metadata_headers}"; then
  printf 'Pre-deploy metadata verification failed for %s at %s (HTTP %s).\n' \
    "${revision}" "${metadata_path}" "${metadata_status}" >&2
  exit 1
fi

if [ "${metadata_path}" = '/v1' ]; then
  metadata_filter='type == "object" and keys == ["name", "version"] and .name == "Sedaia Designs API" and .version == "v1"'
else
  metadata_filter='type == "object"'
fi
if ! jq --exit-status "${metadata_filter}" "${metadata_body}" >/dev/null; then
  printf 'Pre-deploy metadata response failed validation for %s at %s.\n' "${revision}" "${metadata_path}" >&2
  exit 1
fi

jq --null-input \
  --arg checked_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg revision "${revision}" --arg image_digest "${image_digest}" \
  --arg readiness_url "${base_url}/health/ready" \
  --arg metadata_url "${base_url}${metadata_path}" \
  --arg metadata_path "${metadata_path}" \
  --slurpfile metadata_response "${metadata_body}" \
  --argjson legacy_compatibility "$([ "${metadata_path}" = '/v1/' ] && printf true || printf false)" \
  '{checked_at: $checked_at, revision: $revision, image_digest: $image_digest,
    readiness: {passed: true, http_status: 200, url: $readiness_url},
    api_metadata: {passed: true, http_status: 200, url: $metadata_url, path: $metadata_path,
      response: $metadata_response[0]},
    legacy_compatibility: {used: $legacy_compatibility,
      reason: (if $legacy_compatibility then "Pinned pre-Phase-01 serving revision exposes metadata at /v1/." else null end)}}' \
  > "${result_file}"
