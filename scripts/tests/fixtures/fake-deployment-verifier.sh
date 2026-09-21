#!/bin/sh

set -eu

url="$1"
output="$2"
printf 'verify %s\n' "${url}" >> "${FAKE_GCLOUD_STATE}/commands.log"
if [ "${FAIL_CANDIDATE:-false}" = true ] && [ "${url}" = "https://candidate.test" ]; then
  exit 1
fi
if [ "${FAIL_AFTER_PROMOTION:-false}" = true ] && [ -e "${FAKE_GCLOUD_STATE}/promoted" ]; then
  exit 1
fi
jq --null-input --arg url "${url}" '{readiness: {passed: true}, api_metadata: {passed: true}, portfolio_contract: {passed: true}, portfolio_cors: {passed: true}, url: $url}' > "${output}"
