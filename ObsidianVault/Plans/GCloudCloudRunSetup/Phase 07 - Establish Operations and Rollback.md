# Phase 07 - Establish Operations and Rollback

## Status

Repository preparation and the first controlled rollback drill are complete. Cloud Run release manifests, revision-based rollback automation, Cloud Run monitoring filters, and reviewable alert templates are implemented. Hosted alert creation, notification testing, and retention proof remain pending.

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

## Drill evidence - 2026-09-20

- [x] Confirmed source revision `sedaia-api-00003-jwp` served 100 percent of traffic before the drill and used digest `sha256:6bd72440a7ec3e50f54e039903457538177c68475eaaca1a897e09b940d4252b` from successful build `1ab86964-ca14-434b-b8bf-b6699db08bcd`.
- [x] Confirmed rollback revision `sedaia-api-00002-z9z` remained ready and used retained digest `sha256:deb6241027cbe4f661bb2a3a86b5f18a13813b7147f4f1d1e20cb8fe5d47f9d2` from successful build `ab3fbd1d-b7dc-4621-aec0-af7a95d45ace`.
- [x] Shifted 100 percent of traffic to `sedaia-api-00002-z9z` without rebuilding. The generated Cloud Run URL and `https://api.sedaia-designs.org` passed readiness, portfolio HTTP/JSON, and CORS verification by `2026-09-20T22:45:28Z`.
- [x] Restored 100 percent of traffic to `sedaia-api-00003-jwp` without rebuilding. Both endpoints passed the same verification by `2026-09-20T22:45:50Z`.
- [x] Confirmed Cloud Logging correlated successful drill requests with both exact revision names. The full drill, measured from the pre-change capture at `2026-09-20T22:44:49Z` through final verification, completed in 61 seconds; rollback verification completed within 39 seconds of that capture.
- [ ] Confirm alert delivery during a future drill after the hosted policies and owned notification channel are configured. No monitoring policies were present during this drill, so alert behavior was not claimed as verified.

## Exit criterion

A rollback restored a known-good digest without rebuilding, verification passed, and the release and rollback evidence identify the exact revisions. Remaining Phase 07 operational setup is tracked above and does not invalidate the completed rollback-mechanism drill.
