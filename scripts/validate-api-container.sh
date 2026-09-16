#!/usr/bin/env zsh

set -euo pipefail

readonly image_name="${API_VALIDATION_IMAGE:-sedaia-api:validation}"
readonly container_name="sedaia-api-validation-$$"
readonly host_port="${API_VALIDATION_PORT:-18080}"
readonly base_url="http://127.0.0.1:${host_port}"

cleanup() {
  docker rm --force "${container_name}" >/dev/null 2>&1 || true
}

show_container_logs() {
  print -u2 -- "Container logs:"
  docker logs "${container_name}" >&2 || true
}

trap cleanup EXIT INT TERM

if ! docker info >/dev/null 2>&1; then
  print -u2 -- "Docker is unavailable. Start Docker Desktop, then run this configuration again."
  exit 1
fi

print -- "Building ${image_name}..."
docker build --tag "${image_name}" .

print -- "Image metadata:"
docker image inspect "${image_name}" \
  --format 'ID={{.Id}} Size={{.Size}} Architecture={{.Architecture}} OS={{.Os}}'

print -- "Starting ${container_name} on ${base_url}..."
docker run \
  --detach \
  --name "${container_name}" \
  --env PORT=8080 \
  --publish "127.0.0.1:${host_port}:8080" \
  "${image_name}" >/dev/null

ready=false
for attempt in {1..30}; do
  if curl --fail --silent --output /dev/null "${base_url}/health/ready"; then
    ready=true
    break
  fi

  if [[ "$(docker inspect --format '{{.State.Running}}' "${container_name}")" != "true" ]]; then
    print -u2 -- "The API container exited before becoming ready."
    show_container_logs
    exit 1
  fi

  sleep 1
done

if [[ "${ready}" != "true" ]]; then
  print -u2 -- "The API did not become ready within 30 seconds."
  show_container_logs
  exit 1
fi

live_response="$(curl --fail --silent --show-error "${base_url}/health/live")"
if [[ "${live_response}" != "{}" ]]; then
  print -u2 -- "Unexpected response from /health/live: ${live_response}"
  exit 1
fi

root_response="$(curl --fail --silent --show-error "${base_url}/v1/")"
if [[ "${root_response}" != "Hello Ktor!" ]]; then
  print -u2 -- "Unexpected response from /v1/: ${root_response}"
  exit 1
fi

portfolio_response="$(curl --fail --silent --show-error "${base_url}/v1/portfolio/")"
if [[ "${portfolio_response}" != *'"owner":"Sakura Sedaia"'* ]]; then
  print -u2 -- "Unexpected response from /v1/portfolio/: ${portfolio_response}"
  exit 1
fi

print -- "Container validation passed:"
print -- "  GET /health/ready -> HTTP 200"
print -- "  GET /health/live -> HTTP 200"
print -- "  GET /v1/ -> ${root_response}"
print -- "  GET /v1/portfolio/ -> HTTP 200 with the expected owner"
