#!/bin/sh

set -eu

readonly repository_root="$(CDPATH='' cd -- "$(dirname -- "$0")/../.." && pwd)"
readonly verifier="${repository_root}/scripts/verify-api-deployment.sh"
readonly pre_deploy_verifier="${repository_root}/scripts/verify-api-pre-deploy.sh"
readonly test_directory="$(mktemp -d)"
readonly fixture_classpath="$(
  "${repository_root}/gradlew" --quiet --no-configuration-cache :apps:api:printTestRuntimeClasspath
)"
server_pid=""

cleanup() {
  if [ -n "${server_pid}" ]; then
    kill "${server_pid}" 2>/dev/null || true
    wait "${server_pid}" 2>/dev/null || true
  fi
  rm -rf "${test_directory}"
}

trap cleanup EXIT INT TERM

run_case() {
  scenario="$1"
  expected_result="$2"
  port_file="${test_directory}/${scenario}.port"
  output_file="${test_directory}/${scenario}.out"
  result_file="${test_directory}/${scenario}.json"

  java -cp "${fixture_classpath}" ApiFixtureServerKt "${scenario}" "${port_file}" &
  server_pid=$!

  attempts=0
  while [ ! -s "${port_file}" ]; do
    attempts=$((attempts + 1))
    if [ "${attempts}" -ge 50 ]; then
      printf 'Fixture server for %s did not start.\n' "${scenario}" >&2
      exit 1
    fi
    sleep 0.1
  done

  port="$(cat "${port_file}")"
  if DEPLOYMENT_READINESS_TIMEOUT_SECONDS=1 \
    DEPLOYMENT_READINESS_RETRY_DELAY_SECONDS=0 \
    "${verifier}" "http://127.0.0.1:${port}" "${result_file}" >"${output_file}" 2>&1; then
    actual_result="pass"
  else
    actual_result="fail"
  fi

  kill "${server_pid}" 2>/dev/null || true
  wait "${server_pid}" 2>/dev/null || true
  server_pid=""

  if [ "${actual_result}" != "${expected_result}" ]; then
    printf 'Expected %s to %s but it %sed. Output:\n' \
      "${scenario}" "${expected_result}" "${actual_result}" >&2
    cat "${output_file}" >&2
    exit 1
  fi

  if [ "${expected_result}" = "pass" ]; then
    jq --exit-status '
      .readiness.passed == true and
      .api_metadata.passed == true and
      .portfolio_contract.passed == true and
      .portfolio_contract.programming_policy == "non-empty" and
      .portfolio_cors.denied_http_status == 403
    ' "${result_file}" >/dev/null
  elif [ -e "${result_file}" ]; then
    printf 'Failed scenario %s unexpectedly produced success evidence.\n' "${scenario}" >&2
    exit 1
  fi

  printf 'PASS: %s (%s expected)\n' "${scenario}" "${expected_result}"
}

run_case valid pass
run_case malformed-json fail
run_case missing-field fail
run_case wrong-type fail
run_case invalid-cors fail
run_case timeout fail
run_case readiness-non-200 fail
run_case portfolio-non-200 fail

run_pre_deploy_case() {
  scenario="$1"
  revision="$2"
  digest="$3"
  expected_result="$4"
  expected_path="$5"
  port_file="${test_directory}/pre-deploy-${scenario}-${revision}.port"
  output_file="${test_directory}/pre-deploy-${scenario}-${revision}.out"
  result_file="${test_directory}/pre-deploy-${scenario}-${revision}.json"

  java -cp "${fixture_classpath}" ApiFixtureServerKt "${scenario}" "${port_file}" &
  server_pid=$!
  attempts=0
  while [ ! -s "${port_file}" ]; do
    attempts=$((attempts + 1))
    if [ "${attempts}" -ge 50 ]; then
      printf 'Pre-deploy fixture server for %s did not start.\n' "${scenario}" >&2
      exit 1
    fi
    sleep 0.1
  done

  port="$(cat "${port_file}")"
  if "${pre_deploy_verifier}" "http://127.0.0.1:${port}" "${revision}" "${digest}" \
    "${result_file}" >"${output_file}" 2>&1; then
    actual_result=pass
  else
    actual_result=fail
  fi
  kill "${server_pid}" 2>/dev/null || true
  wait "${server_pid}" 2>/dev/null || true
  server_pid=""

  if [ "${actual_result}" != "${expected_result}" ]; then
    printf 'Expected pre-deploy %s for %s to %s but it %sed. Output:\n' \
      "${scenario}" "${revision}" "${expected_result}" "${actual_result}" >&2
    cat "${output_file}" >&2
    exit 1
  fi
  if [ "${expected_result}" = pass ]; then
    if [ "${expected_path}" = '/v1/' ]; then
      jq --exit-status --arg path "${expected_path}" '
        .readiness.passed and .api_metadata.path == $path and
        .api_metadata.http_status == 200 and
        .api_metadata.content_type == "text/plain; charset=utf-8" and
        .api_metadata.response == "Hello Ktor!" and
        .canonical_api_metadata.http_status == 404 and
        .legacy_compatibility.used
      ' "${result_file}" >/dev/null
    else
      jq --exit-status --arg path "${expected_path}" '
        .readiness.passed and .api_metadata.path == $path and
        (.api_metadata.response | type == "object" and length > 0) and
        (.legacy_compatibility.used | not)
      ' "${result_file}" >/dev/null
    fi
  elif [ -e "${result_file}" ]; then
    printf 'Failed pre-deploy scenario unexpectedly produced evidence.\n' >&2
    exit 1
  fi
  printf 'PASS: pre-deploy %s for %s (%s expected)\n' "${scenario}" "${revision}" "${expected_result}"
}

legacy_digest=sha256:13f83e2eb79fc89f2e7ad2a54d694a3b80bdd57107783fca33b126bac2c51598
run_pre_deploy_case valid sedaia-api-current sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc pass /v1
run_pre_deploy_case legacy-metadata sedaia-api-00006-xb4 "${legacy_digest}" pass /v1/
run_pre_deploy_case legacy-metadata sedaia-api-unknown "${legacy_digest}" fail ''
run_pre_deploy_case legacy-metadata sedaia-api-00006-xb4 sha256:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd fail ''
run_pre_deploy_case legacy-wrong-body sedaia-api-00006-xb4 "${legacy_digest}" fail ''
run_pre_deploy_case legacy-wrong-content-type sedaia-api-00006-xb4 "${legacy_digest}" fail ''
run_pre_deploy_case legacy-empty sedaia-api-00006-xb4 "${legacy_digest}" fail ''
run_pre_deploy_case legacy-redirect sedaia-api-00006-xb4 "${legacy_digest}" fail ''
run_pre_deploy_case metadata-unavailable sedaia-api-00006-xb4 "${legacy_digest}" fail ''
run_pre_deploy_case invalid-canonical-metadata sedaia-api-current sha256:cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc fail ''
