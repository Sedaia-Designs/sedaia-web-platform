# Phase 03 - Production Environment

**Status: Repository implementation complete; hosted configuration pending.**
Checked-in deployment and rollback workflows reference `production`, require
`main`, and serialize on `production-api`. This does not prove the hosted
environment, reviewers, branch rules, or variables.

Create the `production` environment, enable the strongest approval control
available, restrict deployment branches to `main`, and define the documented
Google Cloud project and authentication variables required by the Gradle App
Engine plugin. Do not add obsolete platform, registry, region, or runtime-image
variables unless the deployment architecture changes again.

Keep the deployment job on the `production` environment and serialize it with
the `production-api` concurrency group so two Gradle deployments cannot race to
change App Engine traffic.

Exit criterion: production jobs cannot proceed outside the selected approval
and branch restrictions.

Manual setup still required: create the environment, add eligible reviewers,
enable the strongest available approval control, restrict it to `main`, and set
`GCP_WORKLOAD_IDENTITY_PROVIDER` and `GCP_SERVICE_ACCOUNT` as environment
variables. Do not place credentials in those variables.
