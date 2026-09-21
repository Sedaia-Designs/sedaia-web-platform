# Phase 11 - Observability Capacity and Cost Controls

## Goal

Make failures, saturation, abuse, certificate/backup risk, and unexpected spending visible to named humans with actionable runbooks.

## Scope

Logs, metrics, traces where justified, uptime/synthetic checks, alerts/channels, dashboards, SLO signals, privacy/retention, capacity/quotas, budgets, lifecycle, rate/WAF limits, and ownership across all providers.

## Prerequisites

Phase 02 owner/environment matrix, deployed staging components, and Cloud Run remediation monitoring requirements.

## Decisions before execution

Approve service objectives, alert thresholds/windows, notification channels/escalation, telemetry retention/privacy, trace sampling, budget thresholds, expected usage, quotas, and on-call expectations.

## Repository areas and hosted systems

`operations/`, monitoring templates/runbooks, Google Cloud Logging/Monitoring/Cloud SQL/Cloud Run, Cloudflare analytics/R2/Workers/Cache/Images, Vercel observability, DNS/certificate monitoring, external uptime service.

## Ordered steps

- [ ] Complete the four Cloud Run remediation policies and acknowledged notification test without weakening that plan.
- [ ] Define per-surface golden signals and dependency signals: availability, latency, errors, traffic, Cloud Run instances, DB CPU/storage/connections/locks/replication/backups, Worker exceptions/CPU/subrequests, R2 operations/storage, cache hit/egress, image transformations, Vercel errors/builds, certificate expiry, and DNS health.
- [ ] Add external checks for both frontends, API readiness/contract, asset HEAD/range, representative restricted denial/authorized synthetic where secrets can be protected, and the intended non-public SQL behavior.
- [ ] Create dashboards that correlate release/build/revision/schema/Worker/deployment IDs and publication events without logging bearer grants or private data.
- [ ] Attach every actionable alert to an owned channel/runbook, test delivery safely, record acknowledgement, and define escalation/noise review.
- [ ] Set log/metric/evidence retention, access, redaction, and export rules; justify tracing only where cross-provider latency diagnosis benefits outweigh cost/privacy.
- [ ] Configure Google/Cloudflare/Vercel budgets and billing alerts, Cloud SQL storage/connection limits, Cloud Run max instances, Worker/R2/Image limits, cache/lifecycle policy, API/download rate limits, and abuse response.
- [ ] Load-test representative metadata and download authorization paths within safe staging quotas; derive pool, concurrency, timeout, and alert thresholds.
- [ ] Schedule monthly cost/alert review and quarterly access/capacity review after launch.

## Security and operational considerations

Telemetry must not contain secrets, authorization URLs, unnecessary IP/user data, or private object keys. Monitoring identities are read-only. Synthetic credentials are narrowly scoped and rotated. Budget alerts are not hard spending caps unless explicitly designed.

## Test strategy

Trigger each alert safely, acknowledge through the real channel, correlate dashboards/logs with release IDs, verify redaction, simulate provider/dependency failures in staging, run capacity tests, and inspect budget/usage signals.

## Acceptance criteria

Every production surface and critical dependency has actionable owned health signals; alert delivery is human-acknowledged; dashboards identify deployed versions; quotas/budgets/abuse controls are active; runbooks match observed behavior.

## Evidence to retain

Policy/check/dashboard/channel IDs, screenshots/exports where needed, test timestamps/acknowledgements, log redaction samples, retention configuration, load results, capacity calculations, budgets/quotas, cost forecast, and review schedule.

## Rollback or recovery

Revert noisy/incorrect policy configuration to the last reviewed version while retaining a minimal availability alert. Raise limits only through an approved cost/capacity change; use rate limiting or feature withdrawal for abuse rather than disabling core audit logs.

## Dependencies

Depends on Phase 02 and staging outputs from Phases 03 and 06–09. Blocks Phase 13. Cloud Run alert work remains owned by remediation.

## Exit criterion

A named operator receives and can act on a safe synthetic failure for every critical surface/dependency, and capacity/cost controls match the approved launch assumptions.
