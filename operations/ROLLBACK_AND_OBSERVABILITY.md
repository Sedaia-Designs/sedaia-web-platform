# API rollback and observability runbook

The production rollback and incident-review window is **30 days**. GitLab keeps
successful release and rollback manifests for 30 days, and Artifact Registry
cleanup remains in dry-run until its preview proves that both the current and
previous known-good manifest digests are retained. The policy keeps at least the
ten newest `sedaia-api` images and deletes tagged images older than 30 days.

## Initial setup and evidence

Authenticate an operator with Logging, Monitoring, and Artifact Registry admin
access, then run:

```sh
MONITORING_NOTIFICATION_CHANNEL=projects/sedaia-web-platform-api-508804/notificationChannels/CHANNEL_ID \
MONITORING_NOTIFICATION_OWNER='Sedaia production operator' \
scripts/configure-api-operations.sh
scripts/audit-api-rollback-readiness.sh
```

The setup command refuses to continue if `_Default` log retention is shorter
than 30 days. It applies the cleanup policy in dry-run, creates the readiness
uptime check and four enabled alert policies, and attaches the supplied channel.
Review Artifact Registry cleanup audit logs after its background evaluation.
Compare every deletion candidate with the digest in the current and previous
known-good release manifests. Only then enable deletion by rerunning the policy
command with `--no-dry-run`.

Send a test notification from the selected notification channel and record its
timestamp, recipient, and result below. This is deliberately an operator step:
repository automation cannot prove that a human received a notification.

| Check | Evidence |
| --- | --- |
| `_Default` retention is at least 30 days | 30 days, audited 2026-09-16 |
| Cleanup dry-run retains current and previous digests | Policy enabled in dry-run 2026-09-16; digest comparison pending two releases |
| Notification reaches the intended owner | Pending operator test |
| Availability policy enabled | Pending operator setup |
| 5xx rate policy enabled | Pending operator setup |
| p95 latency policy enabled | Pending operator setup |
| Startup-failure policy enabled | Pending operator setup |

## Deploy and roll back

Each successful `deploy-api` job publishes `release-manifests/release.json` only
after readiness, portfolio JSON, CORS, and final traffic checks pass. Download a
known-good manifest before starting a rollback. In a default-branch pipeline,
run the protected manual `rollback-api` job with:

- `ROLLBACK_RELEASE_MANIFEST`: the complete JSON from that artifact;
- `ROLLBACK_REASON`: the incident or drill reason.

The serialized job downloads the manifest artifact from its recorded successful
GitLab job and requires an exact semantic match before validating the production target.
It prints the current and proposed revisions and routes traffic to the recorded
revision if its digest still matches. If the revision has expired, it deploys
the recorded digest without rebuilding. It reruns the production checks and
publishes a 30-day rollback manifest. If verification fails, inspect the service
and use a different verified manifest; the job intentionally does not switch
forward.

## Controlled drill

After two known-good release artifacts exist, schedule a low-traffic window.
Download both manifests, run `rollback-api` using the older one, confirm all
checks and monitoring, and record elapsed time. Restore the newer release using
the same job and its manifest. Do not manufacture an outage.

| Drill field | Evidence |
| --- | --- |
| Date/window | Pending |
| Current and previous manifest job URLs | Pending |
| Rollback pipeline and manifest | Pending |
| Recovery time | Pending |
| Monitoring result | Pending |
| Restore pipeline and manifest | Pending |
| Runbook corrections | Pending |
