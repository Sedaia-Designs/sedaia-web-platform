# Production Readiness

## Summary

Finish the external configuration and production exercises needed to make the
Portfolio/API integration observable and recoverable. Repository automation is
largely implemented; hosted-service state and operational evidence remain the
primary gaps.

## Key context

- Historical source: `../../Pre-Obsidian/DEPLOYMENT_READINESS_PLAN.md`.
- Cloud Run configuration from
  `../../Pre-Obsidian/CLOUD_RUN_CONFIGURATION_PLAN.md` is implemented in both
  deployment and rollback code.
- `operations/ROLLBACK_AND_OBSERVABILITY.md` is the operational runbook and
  evidence table.
- GitHub-specific settings and cutover are tracked in
  [[../GitHubActionsMigration/Orchestration|GitHub Actions migration]].
- On 2026-09-18, `:apps:api:appengineDeploy --no-configuration-cache`
  successfully deployed App Engine Standard service `default`, version
  `20260918t095626`, in project `sedaia-web-platform-api-508804`. This proves
  the Gradle staging and direct Google Cloud deployment path; it does not yet
  prove the planned Cloud Run/GitHub Actions path.

## Recommended order

1. [[Phase 00 - Repository Readiness]]
2. [[Phase 01 - Configure Portfolio API Origin]]
3. [[Phase 02 - Establish Release Evidence and Retention]]
4. [[Phase 03 - Configure Monitoring]]
5. [[Phase 04 - Exercise Deployment and Rollback]]
6. [[Phase 05 - Final Verification]]

## Current status

**In progress.** Repository readiness is complete, and a first direct App
Engine deployment succeeded on 2026-09-18 at
`https://sedaia-web-platform-api-508804.uc.r.appspot.com`. Custom-domain,
Vercel, GitHub Actions/OIDC, monitoring, smoke-test, and rollback evidence
remain pending. The hosting target must also be reconciled: the active
automation and runbooks describe Cloud Run, while the demonstrated deployment
uses App Engine Standard.
