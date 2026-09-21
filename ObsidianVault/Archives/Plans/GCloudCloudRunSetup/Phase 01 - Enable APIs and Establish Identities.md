# Phase 01 - Enable APIs and Establish Identities

## Goal

Enable the required services and create a dedicated Cloud Build identity.

## Commands

```sh
PROJECT_ID=sedaia-web-platform-api-508804
REGION=us-central1

gcloud config set project "$PROJECT_ID"
gcloud config set builds/region "$REGION"
gcloud config set run/region "$REGION"

gcloud services enable \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  run.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  --project="$PROJECT_ID"

gcloud iam service-accounts create sedaia-api-builder \
  --project="$PROJECT_ID" \
  --display-name="Sedaia API Cloud Build deployer"
```

If the final create command reports that the account already exists, describe
it and continue; do not create a second identity.

## Verification

```sh
gcloud artifacts repositories describe sedaia-repo \
  --project="$PROJECT_ID" --location="$REGION"

gcloud iam service-accounts describe \
  sedaia-api-builder@${PROJECT_ID}.iam.gserviceaccount.com \
  --project="$PROJECT_ID"

gcloud iam service-accounts describe \
  sedaia-api-runtime@${PROJECT_ID}.iam.gserviceaccount.com \
  --project="$PROJECT_ID"
```

## Exit criterion

All required APIs are enabled, the Docker repository exists in `us-central1`,
and the build and runtime identities are distinct and enabled.

## Execution evidence

Completed on 2026-09-19 at approximately 13:13–13:14 local time.

- [x] Set the active project to `sedaia-web-platform-api-508804`.
- [x] Set the default Cloud Build and Cloud Run region to `us-central1`.
- [x] Enabled Artifact Registry, Cloud Build, IAM, IAM Credentials, Cloud Run,
  Cloud Logging, and Cloud Monitoring APIs. The enable operation completed
  successfully as
  `operations/acat.p2-937577648690-08a08c1b-a0c7-47b2-82d7-e4e953a25328`.
- [x] Created the dedicated build identity
  `sedaia-api-builder@sedaia-web-platform-api-508804.iam.gserviceaccount.com`
  with display name `Sedaia API Cloud Build deployer` and unique ID
  `103468812939363076353`.
- [x] Verified the distinct runtime identity
  `sedaia-api-runtime@sedaia-web-platform-api-508804.iam.gserviceaccount.com`
  with unique ID `114875515885832259382`.
- [x] Verified Docker repository `sedaia-repo` exists in `us-central1` at
  `us-central1-docker.pkg.dev/sedaia-web-platform-api-508804/sedaia-repo`.

Repository inspection reported a standard Docker repository using a
Google-managed encryption key. Its cleanup policy is still in dry-run mode:

| Policy | Action | Scope |
| --- | --- | --- |
| `delete-production-images-after-30-days` | Delete tagged `sedaia-api` images older than 30 days | Dry run |
| `keep-ten-production-images` | Keep the 10 most recent `sedaia-api` versions | Dry run |

Container vulnerability scanning was disabled because
`containerscanning.googleapis.com` was not enabled. That API is not part of the
Phase 01 required-service list and does not block this phase's exit criterion.

**Result:** Phase 01 is complete. The required APIs are enabled, the regional
Artifact Registry repository exists, and the build and runtime service accounts
are present as separate identities.
