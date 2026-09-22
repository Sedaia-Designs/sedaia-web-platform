#!/bin/sh

set -eu

if [ "$#" -ne 2 ]; then
  printf 'Usage: %s acquire|release LOCK_DIRECTORY\n' "$0" >&2
  exit 2
fi

: "${DEPLOYMENT_LOCK_BUCKET:?DEPLOYMENT_LOCK_BUCKET is required}"
: "${DEPLOYMENT_LOCK_OWNER:?DEPLOYMENT_LOCK_OWNER is required}"

action="$1"
lock_directory="$2"
lock_uri="gs://${DEPLOYMENT_LOCK_BUCKET}/production-api.lock"
lock_file="${lock_directory}/production-api.lock.json"
mkdir -p "${lock_directory}"

case "${action}" in
  acquire)
    jq --null-input \
      --arg owner "${DEPLOYMENT_LOCK_OWNER}" \
      --arg created_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
      '{schema_version: 1, owner: $owner, created_at: $created_at}' > "${lock_file}"
    if ! gcloud storage cp --if-generation-match=0 "${lock_file}" "${lock_uri}"; then
      printf 'Another production API deployment or rollback owns %s.\n' "${lock_uri}" >&2
      exit 1
    fi
    ;;
  release)
    current_lock="${lock_directory}/current-production-api.lock.json"
    if ! gcloud storage cp "${lock_uri}" "${current_lock}"; then
      printf 'The production API lock no longer exists; refusing to remove an unknown lock.\n' >&2
      exit 1
    fi
    if [ "$(jq -r '.owner' "${current_lock}")" != "${DEPLOYMENT_LOCK_OWNER}" ]; then
      printf 'The production API lock is owned by another operation; refusing to remove it.\n' >&2
      exit 1
    fi
    gcloud storage rm "${lock_uri}"
    ;;
  *)
    printf 'Usage: %s acquire|release LOCK_DIRECTORY\n' "$0" >&2
    exit 2
    ;;
esac
