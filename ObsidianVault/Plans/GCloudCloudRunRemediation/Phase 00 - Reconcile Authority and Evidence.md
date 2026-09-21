# Phase 00 - Reconcile Authority and Evidence

## Goal

Establish one current source of truth for deployment ownership, preserve historical evidence, and remove contradictions that could cause an operator to run the wrong production path.

## Work

- [ ] Record the current `main` commit, active regional and global Cloud Build triggers, GitHub deployment and rollback workflow triggers, Cloud Run serving revision, App Engine serving version, and current production DNS target in a dated evidence block.
- [ ] Declare `sedaia-api-main` the routine production deployer. Choose one reviewed disposition for `.github/workflows/deploy-api.yml`: remove it, disable it, or make it a named break-glass workflow that refuses a source commit already deployed by `sedaia-api-main` and records the incident/change reference that justified its use.
- [ ] Keep `.github/workflows/rollback-api.yml` only if its evidence source matches the routine deployment path. Automatic Cloud Build evidence lives in Cloud Storage, while the current rollback workflow accepts only a GitHub deployment-run artifact; unify this contract so every routine release is actually recoverable through the documented operator path.
- [ ] Update `../../../README.md` and `../../../operations/ROLLBACK_AND_OBSERVABILITY.md` to distinguish routine deployment, break-glass deployment, rollback, evidence storage, retention, and responsible identities without future-tense or App Engine ownership language.
- [ ] Update [[../GCloudCloudRunSetup/Orchestration|Google Cloud Run setup]] to point remaining work to this remediation plan while preserving its phase evidence.
- [ ] Reclassify [[../ProductionReadiness/Orchestration|Production readiness]] and [[../GitHubActionsMigration/Orchestration|GitHub Actions migration]] as superseded, historical, or still-active only for named non-overlapping items. Correct their App Engine-era statements rather than silently leaving conflicting instructions active.
- [ ] Update `../README.md` so every active plan has an accurate status and no superseded plan appears independently executable.

## Evidence requirements

- Record exact trigger names and IDs, workflow filenames and events, evidence bucket or artifact source, serving revision and digest, and the document locations changed.
- Preserve old evidence and explain supersession; do not rewrite historical deployment results as though Cloud Run existed when they were recorded.
- Search active operational files for `App Engine`, `appengine`, `eventual`, `blocking manual`, and old portfolio endpoint paths. Classify every remaining match as historical, rollback-only, or an error to remove.

## Exit criterion

One routine deployment path, one compatible rollback evidence path, and one authoritative remediation plan are named consistently across active documentation and automation. No active note directs an operator to deploy the API through App Engine.
