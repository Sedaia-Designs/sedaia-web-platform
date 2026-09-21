# Phase 07 - Deployment Validation

**Status: Repository implementation complete; controlled hosted deployment
pending.** The workflow validates the API, requires `main` and exact manual
confirmation, enters `production`, obtains short-lived OIDC credentials, sets a
deterministic App Engine version, and invokes only the Gradle deployment task.
It verifies the exact resource, traffic, application behavior, and retains a
known-good manifest for 30 days. No controlled GitHub production deployment
evidence is recorded.

Related evidence recorded 2026-09-18: the established build contract,
`./gradlew :apps:api:appengineDeploy --no-configuration-cache`, successfully
built, staged, and deployed App Engine service `default`, version
`20260918t095626`, in the target Google Cloud project. The GitHub workflow does
not need to reimplement deployment. This evidence does not satisfy the phase
because it did not exercise GitHub Actions, OIDC, or the protected `production`
environment.

Run preflight negative tests, verify the
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

Unresolved before final production sign-off: choose and document an App Engine
`automatic_scaling.max_instances` limit based on capacity and cost. No intended
limit is established in the repository, so the implementation does not invent
one.
