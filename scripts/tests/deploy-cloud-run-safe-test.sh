#!/usr/bin/env bash

set -Eeuo pipefail

readonly repository_root="$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)"
readonly test_directory="$(mktemp -d)"
readonly fake_bin="${test_directory}/bin"
trap 'rm -rf "${test_directory}"' EXIT INT TERM
mkdir -p "${fake_bin}"
ln -s "${repository_root}/scripts/tests/fixtures/fake-gcloud.sh" "${fake_bin}/gcloud"

export PATH="${fake_bin}:${PATH}"
export GCP_PROJECT_ID=test-project
export CLOUD_RUN_REGION=us-central1
export CLOUD_RUN_SERVICE=sedaia-api
export RUNTIME_SERVICE_ACCOUNT=runtime@test-project.iam.gserviceaccount.com
export ARTIFACT_REGISTRY_REPOSITORY=sedaia-repo
export CLOUD_BUILD_ID=12345678-1234-1234-1234-123456789abc
export CI_COMMIT_SHA=0123456789abcdef0123456789abcdef01234567
export CI_REPOSITORY=Sedaia-Designs/sedaia-web-platform
export RELEASE_EVIDENCE_BUCKET=test-evidence
export DEPLOYMENT_LOCK_BUCKET=test-locks
export CANONICAL_API_URL=https://api.test
export DEPLOYMENT_VERIFIER="${repository_root}/scripts/tests/fixtures/fake-deployment-verifier.sh"
export PRE_DEPLOY_VERIFIER="${repository_root}/scripts/tests/fixtures/fake-pre-deploy-verifier.sh"
export LEGACY_PRE_DEPLOY_REVISION=sedaia-api-prior
export LEGACY_PRE_DEPLOY_DIGEST=sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

run_scenario() {
  local scenario="$1"
  export FAKE_GCLOUD_STATE="${test_directory}/${scenario}-state"
  mkdir -p "${FAKE_GCLOUD_STATE}"
  "${repository_root}/scripts/deploy-cloud-run-safe.sh" "${test_directory}/${scenario}-evidence"
}

run_scenario success
jq -e '
  .schema_version == 2 and .status == "known-good" and .outcome.promoted and
  .outcome.temporary_tag_removed and
  ([.final_traffic[] | select(.revisionName == "sedaia-api-candidate") | .percent] | add) == 100
' "${test_directory}/success-evidence/release.json" >/dev/null

success_log="${test_directory}/success-state/commands.log"
deploy_line="$(grep -n 'run deploy' "${success_log}" | cut -d: -f1)"
candidate_verify_line="$(grep -n 'verify https://candidate.test' "${success_log}" | cut -d: -f1)"
promote_line="$(grep -n -- '--to-revisions=sedaia-api-candidate=100' "${success_log}" | cut -d: -f1)"
canonical_verify_line="$(grep -n 'verify https://api.test' "${success_log}" | tail -n 1 | cut -d: -f1)"
upload_line="$(grep -n 'storage cp.*/12345678-1234-1234-1234-123456789abc/' "${success_log}" | cut -d: -f1)"
(( deploy_line < candidate_verify_line && candidate_verify_line < promote_line && promote_line < canonical_verify_line && canonical_verify_line < upload_line ))
! grep -q -- '--to-latest' "${success_log}"
jq -e '.verification.pre_deploy_generated_service_url.api_metadata.path == "/v1"' \
  "${test_directory}/success-evidence/release.json" >/dev/null
jq -e '.verification.pre_deploy_generated_service_url.api_metadata.response.version == "v1"' \
  "${test_directory}/success-evidence/release.json" >/dev/null

export USE_LEGACY_PRE_DEPLOY=true
run_scenario legacy-pre-deploy
jq -e '
  .status == "known-good" and
  .verification.pre_deploy_generated_service_url.legacy_compatibility.used and
  .verification.pre_deploy_generated_service_url.api_metadata.path == "/v1/" and
  .verification.pre_deploy_generated_service_url.api_metadata.content_type == "text/plain; charset=utf-8" and
  .verification.pre_deploy_generated_service_url.api_metadata.response == "Hello Ktor!" and
  .verification.candidate.api_metadata.passed
' "${test_directory}/legacy-pre-deploy-evidence/release.json" >/dev/null
legacy_log="${test_directory}/legacy-pre-deploy-state/commands.log"
grep -q 'pre-deploy-verify https://generated.test sedaia-api-prior sha256:aaaaaaaa' "${legacy_log}"
grep -q 'verify https://candidate.test' "${legacy_log}"
unset USE_LEGACY_PRE_DEPLOY

export USE_LEGACY_PRE_DEPLOY=true
export LEGACY_PRE_DEPLOY_REVISION=sedaia-api-other
if run_scenario unknown-legacy-revision; then
  printf 'An unapproved legacy pre-deploy revision unexpectedly succeeded.\n' >&2
  exit 1
fi
unknown_log="${test_directory}/unknown-legacy-revision-state/commands.log"
! grep -q 'run deploy' "${unknown_log}"
unset USE_LEGACY_PRE_DEPLOY
export LEGACY_PRE_DEPLOY_REVISION=sedaia-api-prior

for failure_mode in wrong-body wrong-content-type empty-body redirect wrong-digest non-404-canonical; do
  export PRE_DEPLOY_FAILURE_MODE="${failure_mode}"
  if run_scenario "legacy-${failure_mode}"; then
    printf 'Legacy compatibility failure %s unexpectedly succeeded.\n' "${failure_mode}" >&2
    exit 1
  fi
  ! grep -q 'run deploy' "${test_directory}/legacy-${failure_mode}-state/commands.log"
done
unset PRE_DEPLOY_FAILURE_MODE

export FAIL_CANDIDATE=true
if run_scenario candidate-failure; then
  printf 'A failed candidate verification unexpectedly succeeded.\n' >&2
  exit 1
fi
jq -e '
  .status == "failed" and (.outcome.promoted | not) and
  ([.final_traffic[] | select(.revisionName == "sedaia-api-prior") | .percent] | add) == 100
' "${test_directory}/candidate-failure-evidence/release.json" >/dev/null
failure_log="${test_directory}/candidate-failure-state/commands.log"
! grep -q -- '--to-revisions=sedaia-api-candidate=100' "${failure_log}"
grep -q -- '--remove-tags=build-12345678123412341234123456789abc' "${failure_log}"
grep -q 'storage cp.*/12345678-1234-1234-1234-123456789abc/' "${failure_log}"

unset FAIL_CANDIDATE
export FAIL_AFTER_PROMOTION=true
if run_scenario promotion-failure; then
  printf 'A failed post-promotion verification unexpectedly succeeded.\n' >&2
  exit 1
fi
jq -e '
  .status == "failed" and .outcome.promoted and .outcome.rollback_attempted and .outcome.rollback_passed and
  ([.final_traffic[] | select(.revisionName == "sedaia-api-prior") | .percent] | add) == 100
' "${test_directory}/promotion-failure-evidence/release.json" >/dev/null
promotion_failure_log="${test_directory}/promotion-failure-state/commands.log"
promote_line="$(grep -n -- '--to-revisions=sedaia-api-candidate=100' "${promotion_failure_log}" | cut -d: -f1)"
restore_line="$(grep -n -- '--to-revisions=sedaia-api-prior=100' "${promotion_failure_log}" | cut -d: -f1)"
(( promote_line < restore_line ))
grep -q -- '--remove-tags=build-12345678123412341234123456789abc' "${promotion_failure_log}"
grep -q 'storage cp.*/12345678-1234-1234-1234-123456789abc/' "${promotion_failure_log}"

printf 'Safe Cloud Run ordering, candidate isolation, and post-promotion recovery passed.\n'
