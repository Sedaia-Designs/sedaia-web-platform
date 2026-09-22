#!/bin/sh

set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf 'Usage: %s SERVICE_URL [RESULT_FILE]\n' "$0" >&2
  exit 2
fi

readonly base_url="${1%/}"
readonly result_file="${2:-}"
readonly timeout_seconds="${DEPLOYMENT_READINESS_TIMEOUT_SECONDS:-60}"
readonly retry_delay_seconds="${DEPLOYMENT_READINESS_RETRY_DELAY_SECONDS:-2}"
readonly portfolio_origin="${PORTFOLIO_ORIGIN:-https://sakura-sedaia.com}"
readonly untrusted_origin="${UNTRUSTED_ORIGIN:-https://example.com}"
readonly response_directory="$(mktemp -d)"
readonly readiness_body="${response_directory}/readiness.json"
readonly readiness_headers="${response_directory}/readiness-headers.txt"
readonly metadata_body="${response_directory}/metadata.json"
readonly metadata_headers="${response_directory}/metadata-headers.txt"
readonly portfolio_body="${response_directory}/portfolio.json"
readonly portfolio_headers="${response_directory}/portfolio-headers.txt"
readonly denied_body="${response_directory}/denied-body.txt"
readonly denied_headers="${response_directory}/denied-headers.txt"

cleanup() {
  rm -rf "${response_directory}"
}

trap cleanup EXIT INT TERM

case "${timeout_seconds}" in
  ''|*[!0-9]*)
    printf 'DEPLOYMENT_READINESS_TIMEOUT_SECONDS must be a positive integer.\n' >&2
    exit 2
    ;;
  0)
    printf 'DEPLOYMENT_READINESS_TIMEOUT_SECONDS must be greater than zero.\n' >&2
    exit 2
    ;;
esac

case "${retry_delay_seconds}" in
  ''|*[!0-9]*)
    printf 'DEPLOYMENT_READINESS_RETRY_DELAY_SECONDS must be a non-negative integer.\n' >&2
    exit 2
    ;;
esac

deadline=$(( $(date +%s) + timeout_seconds ))
ready=false

printf 'Waiting up to %s seconds for %s/health/ready...\n' "${timeout_seconds}" "${base_url}"

while [ "$(date +%s)" -lt "${deadline}" ]; do
  readiness_status="000"
  if readiness_status="$(
    curl \
      --silent \
      --show-error \
      --dump-header "${readiness_headers}" \
      --output "${readiness_body}" \
      --write-out '%{http_code}' \
      --connect-timeout 3 \
      --max-time 5 \
      "${base_url}/health/ready"
  )"; then
    if [ "${readiness_status}" = "200" ] &&
      jq --exit-status 'type == "object" and length == 0' "${readiness_body}" >/dev/null &&
      awk 'tolower($0) ~ /^content-type:[[:space:]]*application\/json([[:space:]]*;|\r?$)/ { found = 1 } END { exit !found }' "${readiness_headers}"; then
      ready=true
      break
    fi
  fi

  sleep "${retry_delay_seconds}"
done

if [ "${ready}" != "true" ]; then
  printf 'Readiness check failed with HTTP %s after %s seconds.\n' \
    "${readiness_status}" "${timeout_seconds}" >&2
  if [ -s "${readiness_body}" ]; then
    printf 'Readiness response:\n' >&2
    cat "${readiness_body}" >&2
    printf '\n' >&2
  fi
  exit 1
fi

printf 'Readiness check passed.\n'

metadata_status="$(
  curl \
    --silent \
    --show-error \
    --dump-header "${metadata_headers}" \
    --output "${metadata_body}" \
    --write-out '%{http_code}' \
    --connect-timeout 3 \
    --max-time 10 \
    "${base_url}/v1"
)"

if [ "${metadata_status}" != "200" ] ||
  ! awk 'tolower($0) ~ /^content-type:[[:space:]]*application\/json([[:space:]]*;|\r?$)/ { found = 1 } END { exit !found }' "${metadata_headers}" ||
  ! jq --exit-status '
  type == "object" and
  keys == ["name", "version"] and
  .name == "Sedaia Designs API" and
  .version == "v1"
' "${metadata_body}" >/dev/null; then
  printf 'API metadata contract check failed (HTTP %s).\n' "${metadata_status}" >&2
  cat "${metadata_body}" >&2
  printf '\n' >&2
  exit 1
fi

printf 'API metadata contract check passed.\n'

portfolio_status="$(
  curl \
    --silent \
    --show-error \
    --header "Origin: ${portfolio_origin}" \
    --dump-header "${portfolio_headers}" \
    --output "${portfolio_body}" \
    --write-out '%{http_code}' \
    --connect-timeout 3 \
    --max-time 10 \
    "${base_url}/v1/portfolio/content"
)"

if [ "${portfolio_status}" != "200" ]; then
  printf 'Portfolio smoke test returned HTTP %s instead of HTTP 200.\n' \
    "${portfolio_status}" >&2
  if [ -s "${portfolio_body}" ]; then
    printf 'Portfolio response:\n' >&2
    cat "${portfolio_body}" >&2
    printf '\n' >&2
  fi
  exit 1
fi

allowed_origin="$(
  awk '
    tolower($0) ~ /^access-control-allow-origin:/ {
      sub(/^[^:]*:[[:space:]]*/, "")
      sub(/\r$/, "")
      print
    }
  ' "${portfolio_headers}" | tail -n 1
)"

if [ "${allowed_origin}" != "${portfolio_origin}" ]; then
  printf 'Portfolio CORS check expected Access-Control-Allow-Origin: %s but received %s.\n' \
    "${portfolio_origin}" "${allowed_origin:-<missing>}" >&2
  exit 1
fi

if ! awk 'tolower($0) ~ /^content-type:[[:space:]]*application\/json([[:space:]]*;|\r?$)/ { found = 1 } END { exit !found }' "${portfolio_headers}"; then
  printf 'Portfolio smoke test did not return application/json.\n' >&2
  exit 1
fi

if ! jq --exit-status '
  def nonempty_string: type == "string" and length > 0;
  type == "object" and
  keys == ["contact", "programming"] and
  (.programming | type == "array" and length > 0) and
  all(.programming[];
    type == "object" and
    ((keys - ["documentation"]) == ["description", "projectPage", "sourceCode", "title"]) and
    (.title | nonempty_string) and
    (.description | nonempty_string) and
    (.projectPage | nonempty_string and startswith("https://")) and
    (.sourceCode | nonempty_string and startswith("https://")) and
    (.documentation == null or (.documentation | nonempty_string and startswith("https://")))
  ) and
  (.contact | type == "array" and length > 0) and
  all(.contact[];
    type == "object" and
    keys == ["href", "icon", "label", "type", "value"] and
    (.type | nonempty_string) and
    (.label | nonempty_string) and
    (.icon | nonempty_string) and
    (.value | nonempty_string) and
    (.href | nonempty_string)
  )
' "${portfolio_body}" >/dev/null; then
  printf 'Portfolio smoke test response violated the documented contract.\n' >&2
  cat "${portfolio_body}" >&2
  printf '\n' >&2
  exit 1
fi

denied_status="$(
  curl \
    --silent \
    --show-error \
    --header "Origin: ${untrusted_origin}" \
    --dump-header "${denied_headers}" \
    --output "${denied_body}" \
    --write-out '%{http_code}' \
    --connect-timeout 3 \
    --max-time 10 \
    "${base_url}/v1/portfolio/content"
)"

if [ "${denied_status}" != "403" ] ||
  awk 'tolower($0) ~ /^access-control-allow-origin:/ { found = 1 } END { exit !found }' "${denied_headers}"; then
  printf 'Untrusted-origin CORS check expected HTTP 403 without Access-Control-Allow-Origin but received HTTP %s.\n' \
    "${denied_status}" >&2
  exit 1
fi

printf 'Portfolio smoke test passed with the documented JSON contract and CORS for %s.\n' \
  "${portfolio_origin}"

if [ -n "${result_file}" ]; then
  jq --null-input \
    --arg checked_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg readiness_url "${base_url}/health/ready" \
    --arg metadata_url "${base_url}/v1/" \
    --arg portfolio_url "${base_url}/v1/portfolio/content" \
    --arg portfolio_origin "${portfolio_origin}" \
    --arg untrusted_origin "${untrusted_origin}" \
    '{
      checked_at: $checked_at,
      contract_version: "v1",
      readiness: {
        passed: true,
        http_status: 200,
        content_type: "application/json",
        expected_body: {},
        url: $readiness_url
      },
      api_metadata: {
        passed: true,
        http_status: 200,
        expected_name: "Sedaia Designs API",
        expected_version: "v1",
        url: $metadata_url
      },
      portfolio_contract: {
        passed: true,
        http_status: 200,
        content_type: "application/json",
        programming_policy: "non-empty",
        contact_policy: "non-empty",
        url: $portfolio_url
      },
      portfolio_cors: {
        passed: true,
        allowed_origin: $portfolio_origin,
        denied_origin: $untrusted_origin,
        denied_http_status: 403
      }
    }' > "${result_file}"
fi
