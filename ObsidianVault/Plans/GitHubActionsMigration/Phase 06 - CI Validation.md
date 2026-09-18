# Phase 06 - CI Validation

**Status: Pending hosted run evidence.** The workflow is checked in; pull
request and merged-`main` run URLs are not recorded.

Exercise the API, frontend, and API-contract jobs on a pull request and on
`main`. Confirm path filtering, expected check names, failure reporting, and
successful completion without production credentials. CI may run normal build
and test tasks, but it must not run `appengineDeploy`, request an OIDC token, or
enter the `production` environment.

Exit criterion: all required validation jobs behave correctly in both pull
request and default-branch runs.
