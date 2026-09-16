#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  printf 'Usage: %s SUPPLIED_MANIFEST VERIFIED_OUTPUT\n' "$0" >&2
  exit 2
fi

: "${CI_API_V4_URL:?CI_API_V4_URL is required}"
: "${CI_PROJECT_ID:?CI_PROJECT_ID is required}"
: "${CI_JOB_TOKEN:?CI_JOB_TOKEN is required}"

supplied_manifest="$1"
verified_output="$2"
release_job_id="$(jq -r '.gitlab.job_id // empty' "${supplied_manifest}")"

case "${release_job_id}" in
  ''|*[!0-9]*) printf 'Release manifest has an invalid GitLab job ID.\n' >&2; exit 1 ;;
esac

artifact_url="${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/jobs/${release_job_id}/artifacts/release-manifests/release.json"
curl --fail --silent --show-error --location \
  --header "JOB-TOKEN: ${CI_JOB_TOKEN}" \
  --output "${verified_output}" \
  "${artifact_url}"

supplied_canonical="$(mktemp)"
verified_canonical="$(mktemp)"
trap 'rm -f "${supplied_canonical}" "${verified_canonical}"' EXIT INT TERM
jq --sort-keys --compact-output . "${supplied_manifest}" > "${supplied_canonical}"
jq --sort-keys --compact-output . "${verified_output}" > "${verified_canonical}"

if ! cmp -s "${supplied_canonical}" "${verified_canonical}"; then
  printf 'Supplied manifest does not match the retained artifact from successful job %s.\n' "${release_job_id}" >&2
  exit 1
fi

printf 'Verified release manifest provenance against GitLab job %s.\n' "${release_job_id}"
