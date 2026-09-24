#!/usr/bin/env bash

set -eu

: "${FAKE_GCLOUD_STATE:?FAKE_GCLOUD_STATE is required}"
printf '%s\n' "$*" >> "${FAKE_GCLOUD_STATE}/commands.log"

has_argument() {
  local expected="$1"
  shift
  local argument
  for argument in "$@"; do
    [[ "${argument}" == "${expected}" ]] && return 0
  done
  return 1
}

if [[ "$1 $2" == "storage cp" ]]; then
  source_path="${@: -2:1}"
  destination_path="${@: -1}"
  if [[ "${source_path}" == gs://* ]]; then
    cp "${FAKE_GCLOUD_STATE}/lock.json" "${destination_path}"
  elif [[ "${destination_path}" == gs://*/production-api.lock ]]; then
    if [[ -e "${FAKE_GCLOUD_STATE}/lock.json" ]]; then
      exit 1
    fi
    cp "${source_path}" "${FAKE_GCLOUD_STATE}/lock.json"
  fi
  exit 0
fi

if [[ "$1 $2" == "storage rm" ]]; then
  rm -f "${FAKE_GCLOUD_STATE}/lock.json"
  exit 0
fi

if [[ "$1 $2" == "run deploy" ]]; then
  : > "${FAKE_GCLOUD_STATE}/deployed"
  exit 0
fi

if [[ "$1 $2 $3" == "run revisions list" ]]; then
  printf '%s\n' '[{"metadata":{"name":"sedaia-api-candidate"}}]'
  exit 0
fi

if [[ "$1 $2 $3" == "run revisions describe" ]]; then
  if [[ "$4" == "sedaia-api-prior" ]]; then
    printf '%s\n' '{"metadata":{"name":"sedaia-api-prior"},"status":{"imageDigest":"us-central1-docker.pkg.dev/test-project/sedaia-repo/sedaia-api@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"}}'
  else
    printf '%s\n' '{"metadata":{"name":"sedaia-api-candidate","labels":{"build-id":"12345678-1234-1234-1234-123456789abc"}},"spec":{"serviceAccountName":"runtime@test-project.iam.gserviceaccount.com","containerConcurrency":40,"timeoutSeconds":30,"containers":[{"image":"us-central1-docker.pkg.dev/test-project/sedaia-repo/sedaia-api@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","resources":{"limits":{"cpu":"1","memory":"512Mi"}},"startupProbe":{"httpGet":{"path":"/health/ready"}},"livenessProbe":{"httpGet":{"path":"/health/live"}}}]},"status":{"imageDigest":"us-central1-docker.pkg.dev/test-project/sedaia-repo/sedaia-api@sha256:bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb","conditions":[{"type":"Ready","status":"True"}]}}'
  fi
  exit 0
fi

if [[ "$1 $2 $3" == "run services update-traffic" ]]; then
  if has_argument '--to-revisions=sedaia-api-candidate=100' "$@"; then
    : > "${FAKE_GCLOUD_STATE}/promoted"
  elif has_argument '--to-revisions=sedaia-api-prior=100' "$@"; then
    rm -f "${FAKE_GCLOUD_STATE}/promoted"
  elif has_argument '--remove-tags=b-12345678123412341234123456789abc' "$@"; then
    : > "${FAKE_GCLOUD_STATE}/tag-removed"
  fi
  exit 0
fi

if [[ "$1 $2 $3" == "run services describe" ]]; then
  if [[ -e "${FAKE_GCLOUD_STATE}/promoted" ]]; then
    percent=100
    revision='sedaia-api-candidate'
  else
    percent=100
    revision='sedaia-api-prior'
  fi
  if [[ -e "${FAKE_GCLOUD_STATE}/deployed" && ! -e "${FAKE_GCLOUD_STATE}/tag-removed" ]]; then
    tag=',{"revisionName":"sedaia-api-candidate","percent":0,"tag":"b-12345678123412341234123456789abc","url":"https://candidate.test"}'
  else
    tag=''
  fi
  printf '{"spec":{"template":{"metadata":{"annotations":{"autoscaling.knative.dev/maxScale":"3","autoscaling.knative.dev/minScale":"0"}}}},"status":{"url":"https://generated.test","traffic":[{"revisionName":"%s","percent":%s}%s]}}\n' \
    "${revision}" "${percent}" "${tag}"
  exit 0
fi

printf 'Unsupported fake gcloud command: %s\n' "$*" >&2
exit 1
