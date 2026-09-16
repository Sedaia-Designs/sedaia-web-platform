#!/bin/sh

set -eu

: "${GCP_PROJECT_ID:=sedaia-web-platform-api-508804}"
: "${GCP_REGION:=us-central1}"
: "${CLOUD_RUN_SERVICE:=sedaia-api}"
: "${PUBLIC_API_HOST:=api.sedaia-designs.org}"
: "${MONITORING_NOTIFICATION_CHANNEL:?Set MONITORING_NOTIFICATION_CHANNEL to a tested channel resource name}"
: "${MONITORING_NOTIFICATION_OWNER:?Set MONITORING_NOTIFICATION_OWNER to the operator/team name}"

work_directory="$(mktemp -d)"
trap 'rm -rf "${work_directory}"' EXIT INT TERM

gcloud config set project "${GCP_PROJECT_ID}" >/dev/null

retention_days="$(gcloud logging buckets describe _Default --location=global --project="${GCP_PROJECT_ID}" --format='value(retentionDays)')"
if [ -z "${retention_days}" ] || [ "${retention_days}" -lt 30 ]; then
  printf '_Default log retention must be at least 30 days; found %s.\n' "${retention_days:-unknown}" >&2
  exit 1
fi
printf '_Default log retention: %s days.\n' "${retention_days}"

gcloud artifacts repositories set-cleanup-policies sedaia-repo \
  --project="${GCP_PROJECT_ID}" --location="${GCP_REGION}" \
  --policy=operations/artifact-registry-cleanup.json --dry-run

uptime_name="$(gcloud monitoring uptime list-configs --project="${GCP_PROJECT_ID}" --filter='displayName="sedaia-api readiness"' --format='value(name)' | head -n 1)"
if [ -z "${uptime_name}" ]; then
  uptime_name="$(gcloud monitoring uptime create 'sedaia-api readiness' \
    --project="${GCP_PROJECT_ID}" --resource-type=uptime-url \
    --resource-labels="host=${PUBLIC_API_HOST},project_id=${GCP_PROJECT_ID}" \
    --protocol=https --port=443 --path=/health/ready --request-method=get \
    --status-codes=200 --period=60 --timeout=10 --validate-ssl \
    --format='value(name)')"
fi
uptime_id="${uptime_name##*/}"

startup_filter="resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${CLOUD_RUN_SERVICE}\" AND resource.labels.location=\"${GCP_REGION}\" AND (textPayload:(\"failed to start and listen\" OR \"Container failed to start\") OR jsonPayload.message:(\"failed to start and listen\" OR \"Container failed to start\")) AND NOT textPayload:(\"SIGTERM\" OR \"shutdown\")"
if gcloud logging metrics describe sedaia_api_startup_failures --project="${GCP_PROJECT_ID}" >/dev/null 2>&1; then
  gcloud logging metrics update sedaia_api_startup_failures --project="${GCP_PROJECT_ID}" --description='Cloud Run sedaia-api container startup failures; excludes routine shutdown messages.' --log-filter="${startup_filter}"
else
  gcloud logging metrics create sedaia_api_startup_failures --project="${GCP_PROJECT_ID}" --description='Cloud Run sedaia-api container startup failures; excludes routine shutdown messages.' --log-filter="${startup_filter}"
fi

for template in operations/monitoring/*.json; do
  rendered="${work_directory}/$(basename "${template}")"
  sed \
    -e "s|__NOTIFICATION_CHANNEL__|${MONITORING_NOTIFICATION_CHANNEL}|g" \
    -e "s|__NOTIFICATION_OWNER__|${MONITORING_NOTIFICATION_OWNER}|g" \
    -e "s|__UPTIME_CHECK_ID__|${uptime_id}|g" \
    "${template}" > "${rendered}"
  display_name="$(jq -r '.displayName' "${rendered}")"
  existing="$(gcloud monitoring policies list --project="${GCP_PROJECT_ID}" --filter="displayName=\"${display_name}\"" --format='value(name)' | head -n 1)"
  if [ -n "${existing}" ]; then
    gcloud monitoring policies update "${existing}" --project="${GCP_PROJECT_ID}" --policy-from-file="${rendered}"
  else
    gcloud monitoring policies create --project="${GCP_PROJECT_ID}" --policy-from-file="${rendered}"
  fi
done

printf 'Monitoring policies are enabled. Send a test notification through channel %s and record the result in operations/ROLLBACK_AND_OBSERVABILITY.md.\n' "${MONITORING_NOTIFICATION_CHANNEL}"
