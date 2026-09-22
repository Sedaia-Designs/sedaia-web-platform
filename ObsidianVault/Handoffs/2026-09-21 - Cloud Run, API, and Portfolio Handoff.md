# 2026-09-21 Cloud Run, API, and Portfolio Handoff

## Purpose

This note preserves the full working-session state before logout. It covers the completed Google Cloud Run setup work, remediation Phases 00–02, API route and contract work, Portfolio integration work, repository-skill consolidation, verification results, current Git state, and the exact safe resumption order. Treat the linked plans and committed source as authoritative if any summary here becomes stale.

## Repository state at handoff

- Branch: `dev`.
- Original logout snapshot HEAD: `375f00552e02ea8a3704576463d06e909b97fc41` (`[Docs: portfolio]: Adapted all Portfolio level agent skills to the root repository`).
- Final feature commits created after the original snapshot: `a583ec4` (`[Update: cloud-run]: Make deployments pre-traffic safe`) and `7e89998` (`[Test: ci]: Enforce deployment safeguards`). This handoff is committed separately after those feature commits.
- Protected production branch: local `main` and `origin/main` were observed at `dec6692d6c3948ac0330fdf399137fd3df455260` during the earlier remediation evidence pass; re-fetch before relying on that value.
- Phase 02 implementation is committed as `a583ec4`; CI and the Portfolio deployment hold are committed as `7e89998`.
- The original snapshot contained empty `apps/cdn/placeholder.txt` and `apps/sql/placeholder.txt` entries staged as added but absent from the working tree. The final commit workflow resolved that split index state to the actual filesystem: neither `.txt` file is tracked or present. The intended committed placeholders remain the separate `.md` files from `e24f7fa`.

## Google Cloud Run setup plan

The original [[../Archives/Plans/GCloudCloudRunSetup/Orchestration|GCloud Cloud Run Setup]] plan is now a historical execution record. Do not independently execute its remaining checkboxes; [[../Plans/GCloudCloudRunRemediation/Orchestration|GCloud Cloud Run Remediation]] is the active authority.

### Completed setup work

- Setup Phase 00 reconciled deployment ownership around Cloud Build and retained App Engine only as a rollback fallback.
- Setup Phase 01 enabled the required APIs and established distinct builder and runtime service accounts.
- Setup Phase 02 granted the initial build IAM required for deployment. Its broad roles are intentionally subject to remediation Phase 03; the old unchecked GitHub deployment-account item is superseded by the later automatic-trigger and rollback architecture.
- Setup Phase 03 aligned `cloudbuild.yaml`, `.gcloudignore`, immutable build tagging, runtime settings, probes, resources, and logging.
- Setup Phase 04 completed the first controlled Cloud Run deployment and endpoint verification while leaving App Engine fallback traffic unchanged.
- Setup Phase 05 established the single regional `sedaia-api-main` trigger for protected `main`, removed duplicate/failed trigger attempts, and recorded branch-protection evidence.
- Setup Phase 06 cut `api.sedaia-designs.org` over to the Cloud Run-backed load balancer with active TLS and successful generated/canonical endpoint verification.
- Setup Phase 07 established retained release evidence, Artifact Registry cleanup, an uptime check, a startup-failure logs metric, and a successful rollback-and-restore drill. The four hosted alert policies and owned notification delivery proof remain incomplete and now belong to remediation Phase 04.
- Setup Phase 08 remains incomplete. Its technical deployment, routing, TLS, endpoint, retention, cleanup, and rollback checks passed, but hosted alerting and notification proof remain missing. App Engine service `default`, version `20260918t095626`, was intentionally left serving as the rollback-era fallback pending the remediation retirement gate.

### Last recorded hosted state

- Project: `sedaia-web-platform-api-508804`; region: `us-central1`; Cloud Run service: `sedaia-api`.
- Routine trigger: `sedaia-api-main`, ID `911d239d-69d9-4e1f-add6-27ef029c2469`, regional push trigger for `main` using `cloudbuild.yaml` and `sedaia-api-builder@sedaia-web-platform-api-508804.iam.gserviceaccount.com`.
- Last production state recorded during reconciliation: revision `sedaia-api-00006-xb4`, build `ae95893a-b13c-4a54-9059-87067cc3c580`, digest `sha256:13f83e2eb79fc89f2e7ad2a54d694a3b80bdd57107783fca33b126bac2c51598`, 100 percent traffic. This is historical observation, not a fresh check; verify live state before any operator action.
- Evidence bucket: `gs://sedaia-api-release-evidence-sedaia-web-platform-api-508804`, private with a recorded 30-day retention policy.
- Production hostname: `https://api.sedaia-designs.org`; generated service URL recorded as `https://sedaia-api-gf5626wkfq-uc.a.run.app`.
- Monitoring gap: no hosted alert policies or notification channels were present at the setup audit. Do not claim production observability complete until remediation Phase 04 is evidenced.

## Remediation Phase 00 — authority and evidence

[[../Plans/GCloudCloudRunRemediation/Phase 00 - Reconcile Authority and Evidence|Phase 00]] was completed and committed as `e862a14` (`[Update: cloud-run]: Reconcile deployment and rollback authority`).

- Declared the regional Cloud Build trigger the sole routine production deployer.
- Removed `.github/workflows/deploy-api.yml`, leaving no manual GitHub deployment workflow.
- Retained the protected manual rollback workflow but changed it to consume routine Cloud Build evidence from Cloud Storage.
- Added Cloud Build provenance verification against trigger, repository, branch, commit, revision, and digest.
- Reconciled README, rollback runbook, remediation/setup orchestration, Production Readiness, GitHub Actions Migration, and the plans index.
- Recorded live trigger, Cloud Run, App Engine, DNS, evidence-retention, OIDC, and rollback-identity observations without changing production.
- Phase 00's schema-1 references are historical evidence. Phase 02 commit `a583ec4` upgrades the active release schema and consumers to schema 2.

## Remediation Phase 01 — API contract

[[../Plans/GCloudCloudRunRemediation/Phase 01 - Define and Enforce the API Contract|Phase 01]] was completed and committed as `50f34f9` (`[Update: api]: Enforce the production response contract`).

- Defined `/v1` as exact JSON metadata: `{"name":"Sedaia Designs API","version":"v1"}`.
- Required non-empty `programming` and `contact` arrays with synchronized Kotlin models, route output, tests, and OpenAPI schema.
- Strengthened `scripts/verify-api-deployment.sh` to validate readiness content type/body, metadata, the full portfolio structure, allowed-origin CORS, and denied-origin behavior.
- Added machine-readable verification output and fixture coverage for valid payload, malformed JSON, missing fields, wrong types, invalid CORS, timeouts, readiness failure, and portfolio failure.
- Local Phase 01 validation passed and production was not contacted during that phase.

## Remediation Phase 02 — pre-traffic-safe deployment

[[../Plans/GCloudCloudRunRemediation/Phase 02 - Make Deployment Pre-Traffic Safe|Phase 02]] repository implementation is complete and committed as `a583ec4`, but it is not operationally validated. No production deployment, traffic change, bucket creation, or IAM change was performed during this implementation.

### Implemented in commit `a583ec4`

- Replaced deploy-then-`--to-latest` behavior with `scripts/deploy-cloud-run-safe.sh`.
- Added pre-deploy capture of serving traffic, prior revision/digest, generated URL verification, and canonical verification.
- Added a DNS-safe build-derived traffic tag, `--no-traffic` candidate deployment, label-based candidate resolution, immutable digest/configuration validation, and tagged-URL contract verification.
- Promotes only the exact candidate revision name after verification; `LATEST` and `--to-latest` are prohibited.
- Verifies generated and canonical endpoints after promotion and restores the captured prior traffic allocation if either post-promotion check fails.
- Removes the temporary tag after success or failure and records final service state.
- Makes full commit SHA and repository identity mandatory and format-validated.
- Produces schema-v2 known-good or failure evidence and uploads staged JSON on failure when Cloud Storage remains reachable.
- Replaced the old `scripts/create-cloud-build-release-evidence.sh` success-only path.
- Added `scripts/cloud-run-deployment-lock.sh`, using an atomic Cloud Storage generation precondition so routine deployment and GitHub rollback share one enforceable lock.
- Updated rollback/provenance consumers and `.github/workflows/rollback-api.yml` for schema 2 and the shared lock.
- Added `scripts/tests/deploy-cloud-run-safe-test.sh` plus fake `gcloud`/verifier fixtures covering successful ordering, a technically ready contract-invalid candidate that stays at zero traffic, and automatic restoration after post-promotion failure.
- Added deployment contract and rollout tests to the API CI job.
- Updated `README.md`, `operations/ROLLBACK_AND_OBSERVABILITY.md`, and the Phase 02 plan.

### Validation completed

- `scripts/tests/deploy-cloud-run-safe-test.sh` passed: safe ordering, candidate isolation, and post-promotion recovery.
- `scripts/tests/verify-api-deployment-test.sh` passed all eight positive/negative fixture scenarios.
- `./gradlew :apps:api:check --no-daemon` completed successfully with the permitted temporary Gradle cache after the sandbox initially blocked the default cache and network access.
- Ruby YAML parsing passed for `cloudbuild.yaml`, `.github/workflows/ci.yml`, and `.github/workflows/rollback-api.yml`.
- Bash/POSIX shell syntax checks passed for all changed/new deployment scripts and fixtures.
- `git diff --check` passed.

### Remaining Phase 02 operator work

The Phase 02 note now contains a complete manual checklist and commands. The required order is: provision the separate lock bucket and bucket-scoped IAM; preflight the reviewed repository state; merge and observe one harmless positive build; run the reviewed zero-traffic negative candidate drill with an immediate revert prepared; retain local recovery-harness evidence unless a safe isolated live drill is approved; then record final traffic, evidence, tag cleanup, lock cleanup, and operator acceptance.

The required lock bucket is `gs://sedaia-api-deployment-lock-sedaia-web-platform-api-508804`. It must use uniform bucket-level access and public-access prevention, with no object retention policy and no soft-delete retention. The build and rollback service accounts temporarily need bucket-scoped `roles/storage.objectAdmin`; remediation Phase 03 must measure and narrow those permissions if practical. Do not merge Phase 02 to `main` before the lock bucket and its IAM are ready, because the new production build deliberately fails closed if it cannot acquire the lock.

## API route and response work committed during the session

- `888e98a` renamed the Portfolio API endpoint to `/v1/portfolio/content` across the route, tests, deployment verifier, and architecture documentation.
- `9976842` added portfolio contact response models and contact/icon types.
- `bf9b596` completed the programming portfolio response model.
- `1e006db` added the render response scaffold.
- `5791f7f` made the API serve structured portfolio content, synchronized the response wrapper, tests, OpenAPI schema, and architecture notes.
- `d6d4b69` documented the API project hierarchy in the repository map.
- `50f34f9` then enforced the exact production API contract as described in remediation Phase 01.

## Portfolio site work committed during the session

- `e4642a3` added asynchronous Portfolio content loading, shared client-side types/utilities, Vite proxy configuration, and API-backed contact rendering in the Portfolio application.
- `b747426` standardized Portfolio icon keys and fixed the omit-argument typing issue in `icon-bundle.tsx`.
- `5483a76` removed obsolete `.junie` ignore entries from the Portfolio `.gitignore`.
- `375f005` moved/adapted Portfolio-level agent skills to the repository root, updated root `AGENTS.md`, and simplified `apps/portfolio/AGENTS.md` so shared frontend, accessibility, release, changelog, commit, icon, and migration guidance applies consistently across applications.
- `e24f7fa` added the committed `apps/cdn/placeholder.md` and `apps/sql/placeholder.md` project placeholders. The transient empty `.txt` index entries were not committed.
- Portfolio automatic Git deployment remains blocked for every branch by `apps/portfolio/vercel.json` with `git.deploymentEnabled: false`. CI now asserts that exact safeguard, and `apps/portfolio/README.md` states that manual deployment must wait until the API route, production origin, response contract, and end-to-end behavior are explicitly accepted. The repository has no GitHub Actions frontend deployment workflow; do not use a Vercel dashboard deployment, CLI deployment, or deploy hook before that gate.

## Recommended resumption order

1. Read this handoff, [[../Plans/GCloudCloudRunRemediation/Orchestration|remediation orchestration]], and the full [[../Plans/GCloudCloudRunRemediation/Phase 02 - Make Deployment Pre-Traffic Safe|Phase 02 operator instructions]].
2. Fetch remotes and re-check `dev`, `origin/dev`, `main`, and `origin/main`; do not assume the recorded remote SHAs are still current.
3. Inspect `git status`, the unstaged diff, and the staged diff separately before any new work; the final commit workflow is expected to leave no transient `.txt` placeholder entries.
4. Review commit `a583ec4` and the Phase 02 scripts and manifests, especially lock failure behavior, schema-v2 compatibility, and the operator prerequisite that the lock bucket exist before merge.
5. Rerun the local checks listed below. Use the temporary Gradle cache if the default user cache is unavailable in the execution environment.
6. For future commits, use the repository `git-commit` skill, stage only explicit paths, and review `git diff --staged` before committing.
7. Provision and evidence the lock bucket/IAM through the operator checklist before Phase 02 reaches protected `main`.
8. Complete the positive deployment, negative zero-traffic drill, immediate revert, and evidence recording exactly as documented; do not manufacture a production outage for the post-promotion path.
9. Continue remediation in order: Phase 03 privilege/build reproducibility, Phase 04 hosted monitoring, Phase 05 App Engine retirement only after all gates, then Phase 06 final verification.

## Commands to rerun locally

```sh
scripts/tests/deploy-cloud-run-safe-test.sh
GRADLE_USER_HOME=/private/tmp/sedaia-designs-gradle scripts/tests/verify-api-deployment-test.sh
GRADLE_USER_HOME=/private/tmp/sedaia-designs-gradle ./gradlew :apps:api:check --no-daemon
ruby -e 'require "yaml"; YAML.load_file("cloudbuild.yaml"); YAML.load_file(".github/workflows/ci.yml"); YAML.load_file(".github/workflows/rollback-api.yml"); puts "YAML parse passed"'
bash -n scripts/deploy-cloud-run-safe.sh scripts/tests/deploy-cloud-run-safe-test.sh scripts/tests/fixtures/fake-gcloud.sh
sh -n scripts/cloud-run-deployment-lock.sh scripts/rollback-api.sh scripts/verify-cloud-build-release-manifest-provenance.sh scripts/tests/fixtures/fake-deployment-verifier.sh
git diff --check
git status --short
git diff
git diff --staged
```

## Do not do without an explicit request or satisfied gate

- Do not commit, push, merge, create a pull request, or change production resources merely from this handoff.
- Do not recreate the transient empty `.txt` placeholders; the intended CDN and SQL placeholders use `.md`.
- Do not delete a lock object until its recorded owner is proven inactive.
- Do not use `LATEST` or `--to-latest` for production promotion.
- Do not create a customer-visible outage to test recovery.
- Do not retire or stop the App Engine fallback before remediation Phases 00–04 and the Phase 05 retirement gate are satisfied and evidenced.
- Do not mark Cloud Run setup or remediation complete while hosted alert policies and notification delivery remain unproven.
