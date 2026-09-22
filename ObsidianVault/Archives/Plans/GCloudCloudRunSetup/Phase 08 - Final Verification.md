# Phase 08 - Final Verification

## Status

**Incomplete as of 2026-09-20.** Repository configuration and the live Cloud Run delivery path pass their technical checks, but final cutover is blocked by the missing hosted alert policies and notification delivery proof. Documentation ownership language must also be reconciled before this phase can close. App Engine version `20260918t095626` therefore remains serving as the temporary fallback and no retirement action was taken.

## Goal

Prove the complete production path before retiring App Engine.

## Repository verification

- [x] `./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon` passed on 2026-09-20 (`BUILD SUCCESSFUL`; six actionable tasks, one executed and five up to date).
- [x] `git diff --check` passed on 2026-09-20.
- [x] `../../../../cloudbuild.yaml` uses the intended project-independent substitutions, `CLOUD_LOGGING_ONLY`, startup and liveness probes, zero-to-three instance scaling, CPU `1`, memory `512Mi`, concurrency `40`, timeout `30s`, and the immutable `${BUILD_ID}` tag. Every Phase 03 fixed-string check reported `PASS`.
- [x] `.gcloudignore` upload inventory was reviewed on 2026-09-20. It contains the API source, Gradle wrapper, build configuration, workflows, scripts, and operations files, with no environment files, credentials, keys, `.git`, `.gradle`, dependency directories, frontend packages, Obsidian notes, or build output.
- [ ] README, deployment automation, rollback automation, manifests, and operations documentation consistently describe Cloud Run. All inspected production implementation references use Cloud Run, but delivery-ownership wording is stale: `../../../../README.md` still calls the regional trigger “eventual” and the manual GitHub deployment a blocking production action, while the trigger is already the canonical automatic path; `../../../../operations/ROLLBACK_AND_OBSERVABILITY.md` opens by describing GitHub Actions retention even though automatic Cloud Builds now also retain evidence in Cloud Storage.

## Hosted verification

- [x] Required APIs are enabled in `sedaia-web-platform-api-508804`: Artifact Registry, Cloud Build, IAM, IAM Credentials, Cloud Run, Cloud Logging, and Cloud Monitoring.
- [x] Build and runtime service accounts are distinct and have the plan-required authorization. The builder has project roles `cloudbuild.builds.editor`, `logging.logWriter`, `run.admin`, and `storage.admin`, repository role `artifactregistry.writer`, and `iam.serviceAccountUser` on only the intended runtime identity.
- [x] Artifact Registry contains release build `ae95893a-b13c-4a54-9059-87067cc3c580` at recorded digest `sha256:13f83e2eb79fc89f2e7ad2a54d694a3b80bdd57107783fca33b126bac2c51598`.
- [x] The only enabled deployment trigger is regional `sedaia-api-main`; it targets push branch regex `^main$`, uses `../../../../cloudbuild.yaml`, and has no global duplicate.
- [x] The trigger's build identity is `sedaia-api-builder@sedaia-web-platform-api-508804.iam.gserviceaccount.com`.
- [x] Cloud Run revision `sedaia-api-00006-xb4` uses `sedaia-api-runtime@sedaia-web-platform-api-508804.iam.gserviceaccount.com`, port `8080`, public `allUsers` invocation, ingress `all`, the intended startup and liveness probes, maximum instances `3` with the default minimum `0`, CPU `1`, memory `512Mi`, concurrency `40`, and timeout `30s`. It is the latest ready revision and receives 100 percent of traffic.
- [x] The generated service URL `https://sedaia-api-gf5626wkfq-uc.a.run.app` passed readiness and portfolio HTTP 200, JSON, and CORS verification for `https://sakura-sedaia.com` on 2026-09-20.
- [x] `https://api.sedaia-designs.org` passed the same verification. DNS returned only `8.233.157.128`, and the Google-managed certificate and domain status were both `ACTIVE`.
- [ ] Logs, metrics, alerts, notification delivery, retention, and cleanup policy have complete evidence. Passing evidence exists for the one-minute readiness uptime check, `cloud_run_container_startup_failures` logs-based metric, 30-day Cloud Storage evidence retention, and active delete-after-30-days plus keep-10 Artifact Registry cleanup policies. The project currently has zero alert policies and zero notification channels, so alert coverage and owner delivery are not proven.
- [x] The controlled rollback drill succeeded without rebuilding, restored a known-good revision and immutable digest, verified both endpoints, and restored the newer revision in 61 seconds. See [[Phase 07 - Establish Operations and Rollback]].

## Final verification evidence - 2026-09-20

- Working tree context: verification ran from branch `dev` at commit `55cbda809f528fe6766ba52e38e62cb0d21de65a` with pre-existing uncommitted implementation and documentation changes. No user changes were reset, staged, committed, or pushed.
- Live release: revision `sedaia-api-00006-xb4`, build `ae95893a-b13c-4a54-9059-87067cc3c580`, digest `sha256:13f83e2eb79fc89f2e7ad2a54d694a3b80bdd57107783fca33b126bac2c51598`, traffic `100%` to latest.
- Retention: `gs://sedaia-api-release-evidence-sedaia-web-platform-api-508804` enforces `2,592,000` seconds (30 days) of retention.
- Legacy fallback: App Engine service `default`, version `20260918t095626`, remains `SERVING` with traffic allocation `1.00` pending completion of the monitoring and documentation gates.

## Required follow-up

- [ ] Create and enable readiness availability, HTTP 5xx, p95 latency, and container startup failure policies from the reviewed templates in `../../../../operations/monitoring/`.
- [ ] Attach an owned production notification channel to all four policies and record a received test notification.
- [ ] Reconcile the README and operations runbook so the automatic regional `main` trigger is named as the routine production deployer and the manual GitHub workflow is explicitly break-glass only, including a control that prevents redeploying the same commit during normal operation.
- [ ] Rerun this phase from the reviewed repository state after the follow-up changes reach the protected `main` branch.
- [ ] Only after every checkbox passes, execute and record the App Engine retirement steps below.

## Cutover completion

Only after every applicable item above passes:

1. remove traffic and the domain mapping from App Engine;
2. disable obsolete App Engine deployment and rollback workflows;
3. retain the last App Engine evidence for the agreed audit window;
4. remove the App Engine Gradle plugin and configuration; and
5. update the orchestration/status notes to record Cloud Run as production.

## Exit criterion

Cloud Build reliably deploys the Ktor container to Cloud Run, the canonical API
hostname serves the intended revision, monitoring and rollback are proven, and
no active automation can accidentally deploy the former App Engine path.

**Result on 2026-09-20:** Not yet satisfied. Build, deployment, routing, TLS, endpoint verification, retention, cleanup, and rollback are proven. Monitoring alert policies and notification delivery are not configured, documentation ownership is not yet internally consistent, and App Engine remains active by design until those blockers are resolved.
