# GCloud Cloud Run Setup

## Objective

Deploy the Ktor API from the repository root `../../../Dockerfile` through Cloud Build,
store immutable images in Artifact Registry, and run them as the public Cloud
Run service behind `api.sedaia-designs.org`.

## Fixed target

| Setting | Value |
| --- | --- |
| Project | `sedaia-web-platform-api-508804` |
| Region | `us-central1` |
| Artifact Registry repository | `sedaia-repo` |
| Cloud Run service | `sedaia-api` |
| Runtime identity | `sedaia-api-runtime@sedaia-web-platform-api-508804.iam.gserviceaccount.com` |
| Build identity | `sedaia-api-builder@sedaia-web-platform-api-508804.iam.gserviceaccount.com` |
| Build configuration | `/cloudbuild.yaml` |
| Production hostname | `api.sedaia-designs.org` |
| Source repository | `Sedaia-Designs/sedaia-web-platform` |
| Production branch | `main` |

The Artifact Registry repository and runtime identity were confirmed to exist
on 2026-09-19. At that time, no `sedaia-api` Cloud Run service and no regional
or global Cloud Build trigger existed.

## Recommended order

1. [[Phase 00 - Reconcile Deployment Ownership]]
2. [[Phase 01 - Enable APIs and Establish Identities]]
3. [[Phase 02 - Grant Build IAM]]
4. [[Phase 03 - Align the Build Configuration]]
5. [[Phase 04 - Run the First Controlled Deployment]]
6. [[Phase 05 - Configure the Main Branch Trigger]]
7. [[Phase 06 - Cut Over the API Domain]]
8. [[Phase 07 - Establish Operations and Rollback]]
9. [[Phase 08 - Final Verification]]

Do not configure the automatic trigger until the same revision has passed a
manual build, deployment, and smoke test. Do not move the production hostname
until the generated Cloud Run URL passes the complete verification script.

## Key decisions

- Cloud Build and Cloud Run replace App Engine as the canonical API delivery
  path. The App Engine Gradle plugin, deployment workflow, rollback workflow,
  and documentation must not remain presented as co-equal production paths.
- Builds run as a dedicated service account. The Ktor container runs as the
  separate, already-created runtime service account.
- Images use `${BUILD_ID}` tags and are retained by digest for rollback.
- The service remains publicly invokable because it is a public website API.
- For the production hostname, a global external Application Load Balancer is
  the recommended production endpoint. Direct Cloud Run domain mapping is a
  preview fallback and requires an explicit acceptance of that limitation.

## Definition of done

- A protected `main` update invokes the regional Cloud Build trigger.
- The build tests the Ktor API, builds and pushes the image, and deploys an
  immutable Cloud Run revision.
- Only the selected revision receives 100 percent of production traffic.
- Both the generated Cloud Run URL and `https://api.sedaia-designs.org` pass
  readiness, API response, JSON, and CORS verification.
- A previous known-good image digest can be restored without rebuilding.
- The obsolete App Engine production path is disabled only after rollback and
  observability evidence has been recorded.

## Authoritative references

- [Deploy to Cloud Run using Cloud Build](https://docs.cloud.google.com/build/docs/deploying-builds/deploy-cloud-run)
- [Configure user-specified Cloud Build service accounts](https://docs.cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts)
- [Cloud Run health checks](https://docs.cloud.google.com/run/docs/configuring/healthchecks)
- [Cloud Run custom domains](https://docs.cloud.google.com/run/docs/mapping-custom-domains)
