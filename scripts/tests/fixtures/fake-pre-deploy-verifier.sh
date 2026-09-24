#!/bin/sh

set -eu

url="$1"
revision="$2"
digest="$3"
output="$4"
printf 'pre-deploy-verify %s %s %s\n' "${url}" "${revision}" "${digest}" >> "${FAKE_GCLOUD_STATE}/commands.log"

if [ "${FAIL_PRE_DEPLOY:-false}" = true ] || [ -n "${PRE_DEPLOY_FAILURE_MODE:-}" ] || [ "${USE_LEGACY_PRE_DEPLOY:-false}" = true ]; then
  exit 1
fi

legacy=false
path='/v1'

jq --null-input --arg path "${path}" --argjson legacy "${legacy}" \
  '{readiness: {passed: true}, api_metadata: {passed: true, path: $path,
    content_type: (if $legacy then "text/plain; charset=utf-8" else "application/json" end),
    response: (if $legacy then "Hello Ktor!" else {name: "Sedaia Designs API", version: "v1"} end)},
    legacy_compatibility: {used: $legacy}}' > "${output}"
