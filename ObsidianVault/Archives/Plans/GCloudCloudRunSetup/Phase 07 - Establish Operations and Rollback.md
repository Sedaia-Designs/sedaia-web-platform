# Phase 07 - Establish Operations and Rollback

## Status

Repository preparation, the first controlled rollback drill, release-evidence retention, Artifact Registry cleanup, the readiness uptime check, and the startup-failure logs-based metric are complete. Creating the four hosted alert policies and proving delivery to an owned notification channel remain pending.

## Goal

Make every release observable and recoverable by revision or immutable digest.

## Work

- [x] Change release manifests from App Engine versions to Cloud Run revision names, Artifact Registry digest references, service URL, source commit, build ID, and final traffic allocation.
- [x] Update monitoring filters from `gae_app` and App Engine metrics to Cloud Run `cloud_run_revision` metrics and logs.
- [ ] Create readiness availability, HTTP 5xx, latency, and container startup failure alerts with an owned notification channel. The one-minute HTTPS uptime check `sedaia-api-readiness-kYa3UX3mnFU` and the `cloud_run_container_startup_failures` logs-based metric are live. No notification channel exists, so applying the four policies and proving delivery to the production owner remain pending.
- [x] Apply an Artifact Registry cleanup policy only after proving it retains the current and previous known-good digests for the rollback window. The live policy deletes tagged `sedaia-api` images only after 30 days and independently keeps the 10 most recent images; all known-good digests were younger than 30 days and among the three most recent when dry-run was disabled on 2026-09-20.
- [x] Store successful release evidence for at least 30 days. The private regional bucket `gs://sedaia-api-release-evidence-sedaia-web-platform-api-508804` enforces a 2,592,000-second retention policy, and evidence for builds `1ab86964-ca14-434b-b8bf-b6699db08bcd`, `ab3fbd1d-b7dc-4621-aec0-af7a95d45ace`, and `ae95893a-b13c-4a54-9059-87067cc3c580` is retained there.

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
3. run `../../../../scripts/verify-api-deployment.sh` against the service URL and canonical
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

## Delivery hardening evidence - 2026-09-20

- [x] Added an explicit `route-latest-revision` step after deployment. The rollback drill pinned traffic to a named revision, so later deployments require `gcloud run services update-traffic --to-latest` to restore automatic latest-revision routing.
- [x] Added post-deploy revision, digest, traffic, readiness, JSON, and CORS verification plus retained machine-readable evidence to `cloudbuild.yaml`.
- [x] Build `ae95893a-b13c-4a54-9059-87067cc3c580` deployed revision `sedaia-api-00006-xb4`, which serves 100 percent of traffic at digest `sha256:13f83e2eb79fc89f2e7ad2a54d694a3b80bdd57107783fca33b126bac2c51598`. Both generated and canonical endpoints passed the canonical `/v1/portfolio/content` verification.
- [x] Isolated build `3ed23ee4-d87b-431d-ab4f-623e58916070` validated the final evidence runtime dependencies, release-manifest generation, and upload for build `ae95893a-b13c-4a54-9059-87067cc3c580`.

## Exit criterion

A rollback restored a known-good digest without rebuilding, verification passed, and the release and rollback evidence identify the exact revisions. Remaining Phase 07 operational setup is tracked above and does not invalidate the completed rollback-mechanism drill.
