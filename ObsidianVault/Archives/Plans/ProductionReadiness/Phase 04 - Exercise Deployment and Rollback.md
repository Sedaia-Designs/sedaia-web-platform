# Phase 04 - Exercise Deployment and Rollback

**Status: In progress; one deployment-path proof recorded, rollback still
pending.** Coordinate GitHub workflow proof with Phases 07 and 08 of the GitHub
Actions migration plan.

## Evidence recorded 2026-09-18

- `:apps:api:appengineDeploy --no-configuration-cache` completed successfully
  in 1 minute 6 seconds (`13 actionable tasks: 2 executed, 11 up-to-date`).
- App Engine service `default`, version `20260918t095626`, received traffic at
  `https://sedaia-web-platform-api-508804.uc.r.appspot.com`.
- Staging consumed `apps/api/build/staged-app/app.yaml`; upload, deployment,
  and traffic-split operations completed.
- This is direct Gradle/App Engine evidence, not GitHub Actions, Cloud Run
  immutable-image, smoke-test, monitoring, or rollback evidence.
- App Engine warned that `automatic_scaling.max_instances` is unspecified and
  therefore defaults to 20 for new Standard deployments. Select and declare an
  intentional limit in `app.yaml` before treating scaling as production-ready.

1. Reconcile App Engine with the planned Cloud Run architecture and designate
   the production deployment target.
2. Verify the deployed service's readiness, API JSON, logs, and CORS behavior.
3. Deploy and verify two known-good releases using the selected target's
   immutable version or revision identity.
4. Record the current and previous manifests and platform-specific immutable
   identities: App Engine versions or Cloud Run revisions and image digests.
5. During a low-traffic window, restore the previous release without a rebuild.
6. Run readiness, JSON, CORS, and monitoring checks and measure recovery time.
7. Restore the intended current release through the same immutable process.
8. Record both traffic changes, alert behavior, and runbook corrections.

Exit criterion: rollback and restore both pass production verification and
leave complete evidence.
