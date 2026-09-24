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

response_content_type() {
  headers_file="$1"
  awk '
    index(tolower($0), "content-type:") == 1 {
      value = substr($0, index($0, ":") + 1)
      sub(/^[[:space:]]*/, "", value)
      sub(/\r$/, "", value)
      value = tolower(value)
      gsub(/[[:space:]]*;[[:space:]]*/, "; ", value)
      last = value
    }
    END { print last }
  ' "${headers_file}"
}

is_json_response() {
  [ "$(response_content_type "$1" | cut -d';' -f1)" = 'application/json' ]
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

metadata_content_type="$(response_content_type "${metadata_headers}")"
if [ "${metadata_status}" != "200" ] || ! is_json_response "${metadata_headers}"; then
  printf 'Pre-deploy metadata verification failed for %s at %s (HTTP %s).\n' \
    "${revision}" "${metadata_path}" "${metadata_status}" >&2
  exit 1
fi

if ! jq --exit-status 'type == "object" and keys == ["name", "version"] and .name == "Sedaia Designs API" and .version == "v1"' "${metadata_body}" >/dev/null; then
  printf 'Pre-deploy metadata response failed validation for %s at %s.\n' "${revision}" "${metadata_path}" >&2
  exit 1
fi

jq --null-input \
  --arg checked_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg revision "${revision}" --arg image_digest "${image_digest}" \
  --arg readiness_url "${base_url}/health/ready" \
  --arg metadata_url "${base_url}${metadata_path}" \
  --arg metadata_path "${metadata_path}" \
  --arg metadata_content_type "${metadata_content_type}" \
  --slurpfile metadata_response "${metadata_body}" \
  '{checked_at: $checked_at, revision: $revision, image_digest: $image_digest,
    readiness: {passed: true, http_status: 200, url: $readiness_url},
    api_metadata: {passed: true, http_status: 200, url: $metadata_url, path: $metadata_path,
      content_type: $metadata_content_type, response: $metadata_response[0]},
    legacy_compatibility: {used: false, reason: null}}' \
  > "${result_file}"
