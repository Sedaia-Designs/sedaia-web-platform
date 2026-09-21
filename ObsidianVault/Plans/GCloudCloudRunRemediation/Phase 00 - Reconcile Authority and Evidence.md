# Phase 00 - Reconcile Authority and Evidence

## Goal

Establish one current source of truth for deployment ownership, preserve historical evidence, and remove contradictions that could cause an operator to run the wrong production path.

## Work

- [x] Record the current `main` commit, active regional and global Cloud Build triggers, GitHub deployment and rollback workflow triggers, Cloud Run serving revision, App Engine serving version, and current production DNS target in a dated evidence block.
- [x] Declare `sedaia-api-main` the routine production deployer. Choose one reviewed disposition for `.github/workflows/deploy-api.yml`: remove it, disable it, or make it a named break-glass workflow that refuses a source commit already deployed by `sedaia-api-main` and records the incident/change reference that justified its use.
- [x] Keep `.github/workflows/rollback-api.yml` only if its evidence source matches the routine deployment path. The repository contract uses automatic Cloud Build evidence in Cloud Storage, its provenance verifier passed against build `1ab86964-ca14-434b-b8bf-b6699db08bcd`, and the repository/`main`-restricted rollback identity has the required least-privilege access.
- [x] Update `../../../README.md` and `../../../operations/ROLLBACK_AND_OBSERVABILITY.md` to distinguish routine deployment, break-glass deployment, rollback, evidence storage, retention, and responsible identities without future-tense or App Engine ownership language.
- [x] Update [[../GCloudCloudRunSetup/Orchestration|Google Cloud Run setup]] to point remaining work to this remediation plan while preserving its phase evidence.
- [x] Reclassify [[../ProductionReadiness/Orchestration|Production readiness]] and [[../GitHubActionsMigration/Orchestration|GitHub Actions migration]] as superseded, historical, or still-active only for named non-overlapping items. Correct their App Engine-era statements rather than silently leaving conflicting instructions active.
- [x] Update `../README.md` so every active plan has an accurate status and no superseded plan appears independently executable.

## Evidence — 2026-09-20 reconciliation (observed 2026-09-21T03:36:37Z)

- Authoritative remote `main`: `dec6692d6c3948ac0330fdf399137fd3df455260`; evidence was collected from local branch `dev` at `d6d4b69265d86fad4336a2a4518f840fc37a3a30` without treating the development checkout as deployed state.
- Regional Cloud Build: active trigger `sedaia-api-main`, ID `911d239d-69d9-4e1f-add6-27ef029c2469`, location `us-central1`, event `push` on `^main$`, repository `Sedaia-Designs/sedaia-web-platform`, configuration `cloudbuild.yaml`, identity `sedaia-api-builder@sedaia-web-platform-api-508804.iam.gserviceaccount.com`. Global trigger query returned no triggers.
- GitHub workflows at observation time: active `Deploy API` workflow ID `362710158`, event `workflow_dispatch`; active `Roll back API` workflow ID `362710160`, event `workflow_dispatch`. Phase 00 removes `.github/workflows/deploy-api.yml`, so that manual deployment path becomes absent when this change reaches `main`; `.github/workflows/rollback-api.yml` remains the protected manual recovery path.
- Routine release evidence: `gs://sedaia-api-release-evidence-sedaia-web-platform-api-508804/BUILD_ID/`, private bucket with 30-day retention. Rollback now accepts a Cloud Build UUID, requires a `SUCCESS` build from trigger `911d239d-69d9-4e1f-add6-27ef029c2469` on `main`, validates repository and commit against the schema-1 manifest, and validates the retained revision and digest before traffic changes. GitHub retains rollback-run evidence for 30 days.
- Hosted rollback identity: the authorized pool `github-pool` and active provider `github-provider` exist at `projects/937577648690/locations/global/workloadIdentityPools/github-pool/providers/github-provider`. The provider uses issuer `https://token.actions.githubusercontent.com`, maps subject, repository, and ref claims, and requires both `assertion.repository == 'Sedaia-Designs/sedaia-web-platform'` and `assertion.ref == 'refs/heads/main'`. Dedicated account `sedaia-api-rollback@sedaia-web-platform-api-508804.iam.gserviceaccount.com` exists, and the GitHub `production` environment defines `GCP_WORKLOAD_IDENTITY_PROVIDER` and `GCP_SERVICE_ACCOUNT` with the verified provider and account values. The account grants `roles/iam.workloadIdentityUser` only to the repository-scoped provider principal, has `roles/storage.objectViewer` only on the release-evidence bucket, and has project roles `roles/cloudbuild.builds.viewer` and `roles/run.developer`; the policy audit returned no broader project roles for this account.
- Serving Cloud Run state at observation time: service `sedaia-api`, revision `sedaia-api-00006-xb4`, 100 percent latest-revision traffic, image digest `sha256:13f83e2eb79fc89f2e7ad2a54d694a3b80bdd57107783fca33b126bac2c51598`, build `ae95893a-b13c-4a54-9059-87067cc3c580`. That build reports `FAILURE` because `retain-release-evidence` failed after deploy and traffic movement; the revision remains ready and serving. Phase 00 records but does not change this production state; Phase 02 owns pre-traffic verification and recovery behavior.
- Last successful routine trigger build observed: `1ab86964-ca14-434b-b8bf-b6699db08bcd` for `main` commit `dec6692d6c3948ac0330fdf399137fd3df455260`, with retained manifest for revision `sedaia-api-00003-jwp` and digest `sha256:6bd72440a7ec3e50f54e039903457538177c68475eaaca1a897e09b940d4252b`.
- Legacy App Engine state: service `default`, version `20260918t095626`, status `SERVING`, traffic `1.0`; no App Engine domain mappings were returned. This is rollback-only legacy state pending the Phase 05 gate, not a deployment path.
- Production DNS: `api.sedaia-designs.org` resolves to A record `8.233.157.128`; no AAAA or CNAME answer was returned. This is the Google load-balancer target; Cloud Run's generated URL is `https://sedaia-api-gf5626wkfq-uc.a.run.app`.
- Documents and automation reconciled: `README.md`, `operations/ROLLBACK_AND_OBSERVABILITY.md`, `.github/workflows/deploy-api.yml` (removed), `.github/workflows/rollback-api.yml`, `scripts/verify-cloud-build-release-manifest-provenance.sh`, `scripts/rollback-api.sh`, `ObsidianVault/Plans/README.md`, and the orchestration notes for Production Readiness, GitHub Actions Migration, Google Cloud Run Setup, and this remediation plan.

## Remaining-match classification

- `App Engine` and `appengine` matches under superseded Production Readiness, superseded GitHub Actions Migration, completed setup phases, and archived Monorepo Buildout phases are historical evidence; their orchestration notes explicitly prohibit execution. Matches in remediation Phases 05–06 describe rollback-only legacy state and retirement gates.
- `eventual` and `blocking manual` deployment language was removed from active root and operations documentation. Old portfolio paths in historical phase evidence remain historical; current contract correction belongs to Phase 01.
- No active automation deploys App Engine. The only production deployment entry point is the regional `sedaia-api-main` trigger; the only operator recovery entry point is `.github/workflows/rollback-api.yml` using retained routine-build evidence.

**Result:** Phase 00 implementation is complete. Repository authority, automation, documentation, retained-evidence provenance, the repository/`main`-restricted GitHub OIDC provider, dedicated rollback account, least-privilege IAM bindings, and protected GitHub variables are reconciled. The exit criterion becomes effective when these reviewed repository changes merge to protected `main`, which removes the hosted manual deploy workflow and publishes the compatible rollback workflow. No deployment, traffic change, App Engine retirement, commit, or push was performed during this phase.

## Evidence requirements

- Record exact trigger names and IDs, workflow filenames and events, evidence bucket or artifact source, serving revision and digest, and the document locations changed.
- Preserve old evidence and explain supersession; do not rewrite historical deployment results as though Cloud Run existed when they were recorded.
- Search active operational files for `App Engine`, `appengine`, `eventual`, `blocking manual`, and old portfolio endpoint paths. Classify every remaining match as historical, rollback-only, or an error to remove.

## Exit criterion

One routine deployment path, one compatible rollback evidence path, and one authoritative remediation plan are named consistently across active documentation and automation. No active note directs an operator to deploy the API through App Engine.
