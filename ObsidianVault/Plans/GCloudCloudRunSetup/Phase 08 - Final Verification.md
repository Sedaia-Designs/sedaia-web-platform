# Phase 08 - Final Verification

## Goal

Prove the complete production path before retiring App Engine.

## Repository verification

- [ ] `./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon` passes.
- [ ] `git diff --check` passes.
- [ ] `../../../cloudbuild.yaml` uses the intended project-independent substitutions,
  dedicated logging mode, health checks, bounded scaling, and immutable tag.
- [ ] `.gcloudignore` uploads no secrets, caches, dependencies, or build output.
- [ ] README, deployment automation, rollback automation, manifests, and
  operations documentation consistently describe Cloud Run.

## Hosted verification

- [ ] Required APIs are enabled in `sedaia-web-platform-api-508804`.
- [ ] Build and runtime service accounts are distinct and minimally authorized.
- [ ] Artifact Registry contains the release image and recorded digest.
- [ ] The regional trigger targets only `main` and uses `../../../cloudbuild.yaml`.
- [ ] The trigger's build identity is `sedaia-api-builder@...`.
- [ ] Cloud Run uses `sedaia-api-runtime@...`, port `8080`, public invocation,
  intended ingress, health probes, scaling bounds, resources, concurrency, and
  timeout.
- [ ] The generated service URL passes readiness, JSON, endpoint, and CORS
  verification.
- [ ] `https://api.sedaia-designs.org` passes the same verification with valid
  TLS and expected DNS.
- [ ] Logs, metrics, alerts, notification delivery, retention, and cleanup
  policy have evidence.
- [ ] The controlled rollback drill succeeds without rebuilding.

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
