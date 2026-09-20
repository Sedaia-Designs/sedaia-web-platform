# Phase 04 - Google OIDC

**Status: Repository integration complete; hosted setup and tests pending.** The
workflows request `id-token: write` only in protected jobs and use the two
documented environment variables. No successful read-only GitHub OIDC run or
negative-test evidence is recorded.

Configure Workload Identity Federation for the exact repository and production
environment subject. Grant the dedicated deployer identity only the roles
required for `appengineDeploy` to stage and deploy the `default` App Engine
service, including access to deployment staging storage where required. Do not
reuse the App Engine runtime service account as the GitHub deployer identity.
Then run a read-only positive authentication test and negative tests for an
untrusted branch, pull request, and environment context before authorizing a
deployment.

Exit criterion: only the intended GitHub production context can obtain
short-lived Google credentials, with no stored service-account key.

Manual setup still required: create the provider and a dedicated deployer
service account, constrain the provider attribute condition to the canonical
repository and intended protected context, grant only the App Engine deployment
and staging permissions required by the Gradle task, then record positive and
negative authentication results. The App Engine runtime service account must
not be used as the GitHub deployment identity.
