# Phase 08 - Rollback Validation

**Status: Pending.** Requires two known-good GitHub App Engine deployment
records and an explicit, authenticated traffic-rollback operation.

The Gradle `appengineDeploy` task owns new-version deployment, but does not by
itself define rollback. Add a guarded workflow operation that selects only a
retained, verified App Engine version and changes traffic without rebuilding.
Test rejection of invalid workflow runs, versions, provenance, branches, and
confirmations. After two known-good versions exist, restore the previous
version, verify production, and restore the intended current version through
the same protected environment and OIDC identity.

Exit criterion: rollback accepts only verified App Engine version evidence and
a controlled traffic drill succeeds in both directions without rebuilding.
