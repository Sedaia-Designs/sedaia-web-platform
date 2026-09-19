# API rollback and observability runbook

Production release and rollback evidence is retained by GitHub Actions for 30
days. The rollback unit is an immutable Cloud Run revision of service
`sedaia-api` in `us-central1`, paired with its `sha256` Artifact Registry image
digest. Do not delete a revision or image digest referenced by a retained
known-good manifest. Artifact Registry cleanup policies must retain those
digests for at least as long as the GitHub release artifacts.

## Initial setup and evidence

An operator with appropriate Logging and Monitoring access must configure and
verify:

- an HTTPS uptime check for the Cloud Run service URL's `/health/ready` path;
- enabled alerts for readiness, application 5xx responses, and p95 latency;
- at least 30 days of application log retention;
- a notification channel attached to every production alert; and
- a real test notification received by the named production owner.

The JSON files in `operations/monitoring/` are reviewable policy templates.
Replace their notification-channel and uptime-check placeholders before use and
verify metric descriptors against the target project. Repository configuration
cannot prove that a human received a notification, so record the hosted test.

| Check | Evidence |
| --- | --- |
| `_Default` log retention is at least 30 days | 30 days, audited 2026-09-16; recheck after migration |
| Known-good Cloud Run revisions and image digests remain available for 30 days | Pending two GitHub releases |
| Notification reaches the intended owner | Pending operator test |
| Readiness policy enabled | Pending operator setup |
| Application-error policy enabled | Pending operator setup |
| p95 latency policy enabled | Pending operator setup |

## Deploy and roll back

Each successful `Deploy API` run publishes a release manifest only after the
exact project, region, service, immutable revision and image digest, traffic,
readiness, portfolio JSON, and CORS checks pass. The deployment workflow is
manual, restricted to `main`, gated by the protected `production` environment,
and serialized with the `production-api` concurrency group.

To restore a release, manually run `Roll back API` from `main` with the known-
good deployment workflow run ID, an incident or drill reason, and the exact
confirmation `rollback-production`. The workflow downloads the retained
manifest, verifies its GitHub provenance, and confirms that its Cloud Run
revision still exists with the recorded image digest before changing traffic.
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

| Drill field | Evidence |
| --- | --- |
| Date/window | Pending |
| Current and previous deployment run URLs | Pending |
| Rollback workflow run and manifest | Pending |
| Recovery time | Pending |
| Monitoring and notification result | Pending |
| Restore workflow run and manifest | Pending |
| Runbook corrections | Pending |

The Cloud Run configuration caps the service at three instances. Revisit that
capacity and cost limit using production traffic evidence before raising it.
