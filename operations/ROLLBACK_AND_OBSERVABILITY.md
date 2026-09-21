# API rollback and observability runbook

Routine production release evidence is retained in the private Cloud Storage bucket `gs://sedaia-api-release-evidence-sedaia-web-platform-api-508804/BUILD_ID/` under a 30-day retention policy. Rollback-run evidence is retained by GitHub Actions for 30 days. The rollback unit is an immutable Cloud Run revision of service
`sedaia-api` in `us-central1`, paired with its `sha256` Artifact Registry image
digest. Do not delete a revision or image digest referenced by a retained
known-good manifest. Artifact Registry cleanup policies must retain those
digests for at least as long as the GitHub release artifacts.

## Initial setup and evidence

An operator with appropriate Logging and Monitoring access must configure and
verify:

- a repository-and-`main`-bound GitHub OIDC provider and dedicated rollback service account with Cloud Build read, Cloud Run developer, and release-evidence object-read access;
- `GCP_WORKLOAD_IDENTITY_PROVIDER` and `GCP_SERVICE_ACCOUNT` variables in the protected GitHub `production` environment;
- an HTTPS uptime check for the Cloud Run service URL's `/health/ready` path;
- enabled alerts for readiness, application 5xx responses, p95 latency, and
  container startup failures;
- at least 30 days of application log retention;
- a notification channel attached to every production alert; and
- a real test notification received by the named production owner.

The JSON files in `operations/monitoring/` are reviewable policy templates.
Replace their notification-channel and uptime-check placeholders before use and
verify metric descriptors against the target project. Repository configuration
cannot prove that a human received a notification, so record the hosted test.
The container-startup policy depends on the counter logs-based metric `cloud_run_container_startup_failures`. Its filter is scoped to `sedaia-api` Cloud Run revision system logs in `us-central1` whose text matches a failed `STARTUP` probe. This keeps generic application errors out of the signal and avoids treating slow successful starts as failures.

| Check                                                                         | Evidence                                             |
|-------------------------------------------------------------------------------|------------------------------------------------------|
| `_Default` log retention is at least 30 days                                  | 30 days, verified 2026-09-20                         |
| Known-good release evidence remains available for 30 days                     | Private `us-central1` bucket enforces 30-day retention; current and previous evidence uploaded 2026-09-20 |
| Known-good Cloud Run images survive cleanup                                   | Active delete-after-30-days policy plus keep-10-most-recent override; current and previous digests verified before activation |
| Readiness uptime check enabled                                                | `sedaia-api-readiness-kYa3UX3mnFU`, one-minute HTTPS check for `api.sedaia-designs.org/health/ready` |
| Startup-failure logs-based metric enabled                                     | `cloud_run_container_startup_failures`               |
| Notification reaches the intended owner                                       | Pending operator test                                |
| Readiness policy enabled                                                      | Pending operator setup                               |
| Application-error policy enabled                                              | Pending operator setup                               |
| p95 latency policy enabled                                                    | Pending operator setup                               |
| Container-startup policy enabled                                              | Pending operator setup                               |

Automatic Cloud Builds upload `release.json`, revision state, service state, final traffic, and verification output beneath `gs://sedaia-api-release-evidence-sedaia-web-platform-api-508804/BUILD_ID/`. The bucket enforces public-access prevention, uniform bucket-level access, and a 30-day retention period. The dedicated build service account has object-creator access only.

## Deploy and roll back

Each successful regional `sedaia-api-main` build publishes a release manifest only after the exact repository, `main` commit, project, region, service, immutable revision and image digest, traffic, readiness, portfolio JSON, and CORS checks pass. The trigger is the sole routine deployer and runs `cloudbuild.yaml` as the dedicated builder service account. There is no manual GitHub deployment path.

To restore a release, manually run `Roll back API` from `main` with a successful `sedaia-api-main` Cloud Build ID, an incident or drill reason, and the exact confirmation `rollback-production`. The workflow downloads `release.json` from that build's retained Cloud Storage prefix, verifies the build succeeded from the regional trigger on `main`, and confirms that its Cloud Run revision still exists with the recorded image digest before changing traffic.
It assigns all service traffic to that existing revision, reruns smoke tests,
and uploads machine-readable rollback evidence even when post-change
verification fails. It never rebuilds or redeploys an old release.

If verification fails after traffic changes, treat the run as an active
incident: inspect Cloud Run revision logs and the uploaded before/after service
state, then start another protected rollback using a different verified
known-good manifest. The workflow does not silently claim success or
automatically choose a release.

## Controlled drill

After two known-good GitHub release artifacts exist, schedule a low-traffic
window. Restore the older revision, confirm its digest, smoke tests, and
monitoring, and then restore the intended revision using its own known-good run
ID. Do not manufacture an outage.

| Drill field                        | Evidence                                                                                                                                                             |
|------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Date/window                        | 2026-09-20 22:44:49Z through 22:45:50Z                                                                                                                               |
| Current and previous releases      | `sedaia-api-00003-jwp` / build `1ab86964-ca14-434b-b8bf-b6699db08bcd`; `sedaia-api-00002-z9z` / build `ab3fbd1d-b7dc-4621-aec0-af7a95d45ace`                         |
| Rollback result                    | 100 percent traffic to `sedaia-api-00002-z9z`; generated and canonical endpoint verification passed                                                                  |
| Recovery time                      | Rollback verified within 39 seconds of the pre-change capture; full rollback-and-restore drill completed in 61 seconds                                               |
| Monitoring and notification result | Request logs correlated with both revisions; hosted alert policies and notification delivery remain pending                                                          |
| Restore result                     | 100 percent traffic restored to `sedaia-api-00003-jwp`; generated and canonical endpoint verification passed                                                         |
| Runbook corrections                | Record automatic Cloud Build IDs and immutable digests when no GitHub deployment artifact exists; do not claim alert validation until hosted policies are configured |

After any rollback to a named revision, the next deployment must explicitly restore latest-revision routing. `cloudbuild.yaml` does this in `route-latest-revision` before post-deploy verification; omitting this step can create a healthy revision without assigning it production traffic.

The Cloud Run configuration caps the service at three instances. Revisit that
capacity and cost limit using production traffic evidence before raising it.
