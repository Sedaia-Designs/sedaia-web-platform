# Phase 08 - Rollback Validation

**Status: Repository implementation complete; hosted drill pending.** Rollback
requires a successful manual deployment run from `main`, validates its retained
known-good manifest against the GitHub API, confirms the App Engine version
still exists, and assigns traffic without rebuilding. Two known-good GitHub App
Engine deployment records and a controlled authenticated drill are still
required.

The Gradle `appengineDeploy` task owns new-version deployment; the guarded
rollback workflow owns traffic restoration. Test rejection of invalid workflow
runs, versions, provenance, branches, and
confirmations. After two known-good versions exist, restore the previous
version, verify production, and restore the intended current version through
the same protected environment and OIDC identity.

Exit criterion: rollback accepts only verified App Engine version evidence and
a controlled traffic drill succeeds in both directions without rebuilding.
