# GitHub Actions Migration

## Summary

Validate GitHub Actions as the production CI/CD path while retaining GitLab as
the operational fallback. This plan covers repository controls, GitHub OIDC,
protected deployment and rollback, evidence collection, and the final cutover
decision. It does not authorize removal of GitLab configuration.

## Key context

- The API Gradle build owns App Engine assembly, staging, and deployment through
  `./gradlew :apps:api:appengineDeploy --no-configuration-cache`. GitHub Actions
  should invoke this contract rather than duplicate Google Cloud deployment
  commands.
- CI/CD is responsible for validation, protected-environment guardrails,
  short-lived authentication, serialized execution, post-deployment checks,
  and retained evidence.
- Existing candidate deployment and rollback workflows still describe Cloud
  Run and must be aligned with the App Engine deployment contract before hosted
  validation.
- Production workflows use the `production` environment and the
  `production-api` concurrency group.
- GitHub must use short-lived Google credentials through Workload Identity
  Federation; no service-account key may be stored.
- The original detailed checklist and evidence gathered before this vault
  structure was adopted is preserved in
  `../../Pre-Obsidian/GITHUB_UI_VALIDATION_PLAN.md`.

## Current status

**In progress.** The build-owned App Engine deployment path is proven by the
successful direct deployment on 2026-09-18. GitHub workflow alignment,
Actions policy, environment protection, OIDC, ruleset, hosted CI, controlled
deployment, rollback, stability, and cutover remain pending. Hosted state must
not be inferred from workflow files or from the direct Gradle deployment.

## Recommended order

1. [[Phase 00 - Capability Gate]]
2. [[Phase 01 - Repository Ownership]]
3. [[Phase 02 - Actions Policy]]
4. [[Phase 03 - Production Environment]]
5. [[Phase 04 - Google OIDC]]
6. [[Phase 05 - Main Ruleset]]
7. [[Phase 06 - CI Validation]]
8. [[Phase 07 - Deployment Validation]]
9. [[Phase 08 - Rollback Validation]]
10. [[Phase 09 - Stability Observation]]
11. [[Phase 10 - Cutover Decision]]
12. [[Phase 11 - Final Verification]]

Complete phases in order. Record evidence in the relevant phase note before
advancing. A phase with an unmet exit criterion remains open.

## Evidence register

| Phase | Status | Evidence location |
| --- | --- | --- |
| 00 | Complete | Historical plan decision table dated 2026-09-16 |
| 01 | Complete with deferred team-access recheck | Historical plan Phase 1 |
| 02–06 | Pending hosted validation | Record URLs and dated results in each phase note |
| 07 | Pending workflow alignment and hosted validation | Invoke the established Gradle App Engine deployment task |
| 08–10 | Pending hosted validation | Record URLs and dated results in each phase note |
| 11 | Pending | Complete only after every prior phase passes |
