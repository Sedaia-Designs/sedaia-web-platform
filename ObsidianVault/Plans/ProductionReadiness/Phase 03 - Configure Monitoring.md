# Phase 03 - Configure Monitoring

**Status: Pending operator setup.** Configuration files exist, but the
historical audit found no deployed uptime check or alert policies.

1. Supply a tested notification channel and accountable owner.
2. Apply availability, 5xx-rate, p95-latency, and startup-failure monitoring.
3. Verify every policy is scoped to `sedaia-api` in `us-central1`.
4. Send a test notification and record recipient, timestamp, and result.
5. Link each alert to symptoms, first checks, dashboards or logs, and its
   rollback decision point.

Exit criterion: all policies are enabled and a human has confirmed receipt of
the notification test.
