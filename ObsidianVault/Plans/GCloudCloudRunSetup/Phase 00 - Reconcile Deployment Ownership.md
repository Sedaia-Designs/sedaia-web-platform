# Phase 00 - Reconcile Deployment Ownership

## Goal

Make Cloud Build and Cloud Run the unambiguous production path before changing
hosted resources.

## Work

- [x] Record the current App Engine version and traffic allocation:

  ```sh
  gcloud app versions list \
    --project=sedaia-web-platform-api-508804 \
    --service=default

# Output
SERVICE  VERSION.ID       TRAFFIC_SPLIT  LAST_DEPLOYED              SERVING_STATUS
default  20260918t095626  1.00           2026-09-18T09:57:16-05:00  SERVING
  ```

- [x] Keep the currently serving App Engine version available as the rollback fallback throughout
	the Cloud Run cutover.
- [x] Update `../../../.github/workflows/deploy-api.yml`, `.github/workflows/rollback-api.yml`, release-manifest scripts, monitoring, and the README so they describe Cloud Run revisions and image digests.
- [x] Remove the App Engine Gradle plugin and `../../../apps/api/src/main/appengine/app.yaml`
  only after the Cloud Run deployment and rollback workflows are implemented.
- [x] Decide whether GitHub Actions invokes Cloud Build or whether the Cloud
  Build GitHub trigger is the sole production deployer. Do not leave both able
  to deploy automatically from the same `main` commit.

  **Decision:** Cloud Build owns production image creation and Cloud Run
  deployment through `../../../cloudbuild.yaml`. The protected GitHub workflow
  is a manual orchestrator that submits this configuration and records release
  evidence; it does not contain a second build/deploy implementation. The
  planned regional `main` trigger will invoke the same Cloud Build configuration.
  It must replace, rather than run alongside, manual dispatch for routine
  production releases after the controlled deployment is proven.

## Exit criterion

The repository has one named production deployment owner, while the last known
good App Engine version remains available only as a temporary cutover fallback.

**Complete:** Cloud Build is the named deployment owner. App Engine deployment
code has been removed from the repository, while version `20260918t095626`
remains serving externally as the temporary fallback until cutover verification
is complete.
