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
readonly response_directory="$(mktemp -d)"
readonly readiness_body="${response_directory}/readiness.json"
readonly portfolio_body="${response_directory}/portfolio.json"
readonly portfolio_headers="${response_directory}/portfolio-headers.txt"

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
      --output "${readiness_body}" \
      --write-out '%{http_code}' \
      --connect-timeout 3 \
      --max-time 5 \
      "${base_url}/health/ready"
  )"; then
    if [ "${readiness_status}" = "200" ] && jq --exit-status . "${readiness_body}" >/dev/null; then
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
    "${base_url}/v1/portfolio/"
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

if ! jq --exit-status 'type == "object"' "${portfolio_body}" >/dev/null; then
  printf 'Portfolio smoke test did not return a JSON object.\n' >&2
  cat "${portfolio_body}" >&2
  printf '\n' >&2
  exit 1
fi

printf 'Portfolio smoke test passed with HTTP 200, JSON, and CORS for %s.\n' \
  "${portfolio_origin}"

if [ -n "${result_file}" ]; then
  jq --null-input \
    --arg checked_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg readiness_url "${base_url}/health/ready" \
    --arg portfolio_url "${base_url}/v1/portfolio/" \
    --arg portfolio_origin "${portfolio_origin}" \
    '{
      checked_at: $checked_at,
      readiness: {passed: true, http_status: 200, url: $readiness_url},
      portfolio_json: {passed: true, http_status: 200, url: $portfolio_url},
      portfolio_cors: {passed: true, allowed_origin: $portfolio_origin}
    }' > "${result_file}"
fi
