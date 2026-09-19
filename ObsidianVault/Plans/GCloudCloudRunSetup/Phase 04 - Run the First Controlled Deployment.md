# Phase 04 - Run the First Controlled Deployment

## Goal

Create the first Cloud Run service through a deliberate manual Cloud Build.

## Preflight

```sh
git status --short
git rev-parse HEAD
gcloud auth list
gcloud config list
```

Run from a reviewed commit. Do not upload unrelated local changes.

## Submit

```sh
PROJECT_ID=sedaia-web-platform-api-508804
REGION=us-central1
BUILD_SA=projects/${PROJECT_ID}/serviceAccounts/sedaia-api-builder@${PROJECT_ID}.iam.gserviceaccount.com

gcloud builds submit . \
  --config=cloudbuild.yaml \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --service-account="$BUILD_SA"
```

## Inspect and verify

```sh
gcloud run services describe sedaia-api \
  --project="$PROJECT_ID" --region="$REGION" --format=export

SERVICE_URL="$(gcloud run services describe sedaia-api \
  --project="$PROJECT_ID" --region="$REGION" \
  --format='value(status.url)')"

scripts/verify-api-deployment.sh "$SERVICE_URL"

curl --fail --show-error --silent "$SERVICE_URL/health/live"
curl --fail --show-error --silent "$SERVICE_URL/health/ready"
```

Record the build ID, image URI, image digest, revision name, service URL, source
commit, verification output, and timestamp in release evidence.

## Failure handling

- A failure before deployment leaves production unchanged; repair IAM or the
  build configuration and submit a new build.
- A failing new revision must not be assigned production traffic. Inspect its
  logs with `gcloud run services logs read sedaia-api`.
- Keep App Engine traffic unchanged during this phase.

## Exit criterion

The generated Cloud Run URL passes the repository verification script and the
deployed revision resolves to the expected Artifact Registry digest.
