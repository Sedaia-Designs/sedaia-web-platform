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

## Verification evidence

Verified on 2026-09-19 at 18:54–18:56 UTC in tmux session `first-deployment`.

- [x] Cloud Build `d67bd95a-f421-4d2a-83a2-72e4d0c835c2` completed successfully in 6m48s.
- [x] Source commit: `4dbbcd48b1fab680408d6db2f20ee7f00225ed98`.
- [x] Image URI: `us-central1-docker.pkg.dev/sedaia-web-platform-api-508804/sedaia-repo/sedaia-api@sha256:b7bec0cae339c5efbc9e1d82d636f9e87eb056da5f19a09596610f12a23c5f3f`.
- [x] Image digest: `sha256:b7bec0cae339c5efbc9e1d82d636f9e87eb056da5f19a09596610f12a23c5f3f`.
- [x] Cloud Run revision: `sedaia-api-00001-8sm`.
- [x] Service URL: `https://sedaia-api-gf5626wkfq-uc.a.run.app`.
- [x] Revision conditions report `Ready`, `Active`, `ContainerHealthy`, `ContainerReady`, and `ResourcesAvailable` as true.
- [x] The latest-created and latest-ready revision both equal `sedaia-api-00001-8sm`, which receives 100 percent of service traffic.
- [x] `scripts/verify-api-deployment.sh` passed readiness, portfolio HTTP/JSON, and CORS verification for `https://sakura-sedaia.com`.
- [x] Direct `/health/live` and `/health/ready` requests both succeeded and returned `{}`.
- [x] App Engine fallback traffic remained unchanged at `20260918t095626=1.0`.

Inspection established that Cloud Run reports `status.imageDigest` as the full digest-qualified image URI rather than a bare `sha256` value. Deployment and rollback verification were aligned with that observed API representation.

**Result:** Phase 04 is complete. The first controlled Cloud Build produced a healthy Cloud Run revision whose deployed image resolves to the expected Artifact Registry digest, and the generated service URL passed the complete repository verification.
