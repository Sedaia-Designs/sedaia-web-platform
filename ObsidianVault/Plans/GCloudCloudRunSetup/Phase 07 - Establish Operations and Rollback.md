# Phase 07 - Establish Operations and Rollback

## Status

Repository preparation is in progress. Cloud Run release manifests, revision-based rollback automation, Cloud Run monitoring filters, and reviewable alert templates are implemented. Hosted alert creation, notification testing, retention proof, and the controlled rollback drill remain pending.

## Goal

Make every release observable and recoverable by revision or immutable digest.

## Work

- [x] Change release manifests from App Engine versions to Cloud Run revision names, Artifact Registry digest references, service URL, source commit, build ID, and final traffic allocation.
- [x] Update monitoring filters from `gae_app` and App Engine metrics to Cloud Run `cloud_run_revision` metrics and logs.
- [ ] Create readiness availability, HTTP 5xx, latency, and container startup failure alerts with an owned notification channel. Reviewable policy templates now cover all four signals; applying them and proving delivery to the production owner remain pending.
- [ ] Apply an Artifact Registry cleanup policy only after proving it retains
  the current and previous known-good digests for the rollback window.
- [ ] Store successful release evidence for at least 30 days.

## Rollback procedure

Prefer shifting traffic to an existing healthy known-good revision:

```sh
gcloud run services update-traffic sedaia-api \
  --project=sedaia-web-platform-api-508804 \
  --region=us-central1 \
  --to-revisions=KNOWN_GOOD_REVISION=100
```

If that revision no longer exists, redeploy the recorded digest reference—never
a mutable tag—and rerun verification before confirming recovery.

## Controlled drill

After two known-good Cloud Run releases exist, perform a low-traffic drill:

1. record the current revision and digest;
2. route traffic to the previous known-good revision;
3. run `../../../scripts/verify-api-deployment.sh` against the service URL and canonical
   hostname;
4. confirm alerts and logs remain usable;
5. restore the newer revision; and
6. record elapsed recovery time and any corrections to the runbook.

## Exit criterion

A rollback restores a known-good digest without rebuilding, verification
passes, and the release and rollback evidence identify the exact revisions.
