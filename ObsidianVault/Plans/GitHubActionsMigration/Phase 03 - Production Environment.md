# Phase 03 - Production Environment

**Status: Pending hosted verification.** Checked-in workflows reference the
environment, but that does not prove its reviewers, branch rules, or variables.

Create the `production` environment, enable the strongest approval control
available, restrict deployment branches to `main`, and define the documented
Google Cloud project and authentication variables required by the Gradle App
Engine plugin. Do not add container registry, Cloud Run service, region, or
runtime-image variables unless the deployment architecture changes again.

Keep the deployment job on the `production` environment and serialize it with
the `production-api` concurrency group so two Gradle deployments cannot race to
change App Engine traffic.

Exit criterion: production jobs cannot proceed outside the selected approval
and branch restrictions.
