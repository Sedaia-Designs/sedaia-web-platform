#!/bin/sh

set -eu

: "${GCP_PROJECT_ID:=sedaia-web-platform-api-508804}"
: "${GCP_REGION:=us-central1}"
: "${ARTIFACT_REGISTRY_REPO:=sedaia-repo}"
: "${CLOUD_RUN_SERVICE:=sedaia-api}"

printf 'Logging retention:\n'
gcloud logging buckets describe _Default --location=global --project="${GCP_PROJECT_ID}" --format='table(name,retentionDays,locked)'
printf '\nArtifact Registry cleanup configuration:\n'
gcloud artifacts repositories describe "${ARTIFACT_REGISTRY_REPO}" --location="${GCP_REGION}" --project="${GCP_PROJECT_ID}" --format='yaml(cleanupPolicyDryRun,cleanupPolicies)'
printf '\nCurrent Cloud Run traffic:\n'
if ! gcloud run services describe "${CLOUD_RUN_SERVICE}" --region="${GCP_REGION}" --project="${GCP_PROJECT_ID}" --format='table(status.traffic.revisionName,status.traffic.percent,status.traffic.tag)'; then
  printf 'Service is not deployed.\n'
fi
printf '\nMonitoring policies:\n'
gcloud monitoring policies list --project="${GCP_PROJECT_ID}" --filter='displayName:sedaia-api' --format='table(displayName,enabled,name)'
printf '\nUptime checks:\n'
gcloud monitoring uptime list-configs --project="${GCP_PROJECT_ID}" --filter='displayName:sedaia-api' --format='table(displayName,name)'
