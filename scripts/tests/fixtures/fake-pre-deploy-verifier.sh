#!/bin/sh

set -eu

url="$1"
revision="$2"
digest="$3"
output="$4"
printf 'pre-deploy-verify %s %s %s\n' "${url}" "${revision}" "${digest}" >> "${FAKE_GCLOUD_STATE}/commands.log"

if [ "${FAIL_PRE_DEPLOY:-false}" = true ]; then
  exit 1
fi

if [ "${USE_LEGACY_PRE_DEPLOY:-false}" = true ]; then
  if [ "${revision}" != "${LEGACY_PRE_DEPLOY_REVISION}" ] || [ "${digest}" != "${LEGACY_PRE_DEPLOY_DIGEST}" ]; then
    exit 1
  fi
  legacy=true
  path='/v1/'
else
  legacy=false
  path='/v1'
fi

jq --null-input --arg path "${path}" --argjson legacy "${legacy}" \
  '{readiness: {passed: true}, api_metadata: {passed: true, path: $path,
    response: {name: "Sedaia Designs API", version: (if $legacy then "legacy" else "v1" end)}},
    legacy_compatibility: {used: $legacy}}' > "${output}"
