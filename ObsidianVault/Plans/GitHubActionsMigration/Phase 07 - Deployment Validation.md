# Phase 07 - Deployment Validation

**Status: Pending.** Repository automation exists, but no controlled GitHub
production deployment evidence is recorded.

Related evidence recorded 2026-09-18: the established build contract,
`./gradlew :apps:api:appengineDeploy --no-configuration-cache`, successfully
built, staged, and deployed App Engine service `default`, version
`20260918t095626`, in the target Google Cloud project. The GitHub workflow does
not need to reimplement deployment. This evidence does not satisfy the phase
because it did not exercise GitHub Actions, OIDC, or the protected `production`
environment.

Update the workflow to install the required Java/Gradle and Google Cloud
prerequisites, authenticate through OIDC, and invoke only the established
Gradle deployment task. Run preflight negative tests, verify the
protected-environment gate and concurrency behavior, then carry out one
controlled deployment from reviewed `main`.

Confirm and retain:

1. initiating commit SHA and workflow run URL;
2. approval and authenticated deployer identity;
3. Gradle task result and generated App Engine version;
4. target project, service, deployed URL, and final traffic state;
5. readiness, JSON, and CORS smoke-test results; and
6. logs and artifacts for the selected retention period.

Exit criterion: a reviewed deployment from `main` succeeds and leaves complete
30-day evidence while invalid invocations fail safely.
