# Phase 04 - Complete Monitoring and Operational Proof

## Goal

Turn the existing uptime check, logs-based metric, and policy templates into validated alerts that reach an accountable production owner.

## Work

- [ ] Select the owned notification channel and named primary and backup responders. Record only non-sensitive identifiers in the vault; do not store verification codes or credentials.
- [ ] Validate each JSON template in `../../../operations/monitoring/` against current metric descriptors and resource labels before creation. Confirm units, aligners, reducers, threshold windows, missing-data behavior, and matching-resource semantics.
- [ ] Replace `__NOTIFICATION_CHANNEL__`, `__NOTIFICATION_OWNER__`, and `__UPTIME_CHECK_ID__` through a repeatable rendering script or documented command that fails if any placeholder remains.
- [ ] Create the readiness availability, HTTP 5xx ratio with minimum traffic, p95 latency, and container startup failure policies. Record policy names, IDs, enabled state, conditions, notification channel, and runbook links.[^platform-observability]
- [ ] Send a notification-channel test and record recipient, UTC timestamp, delivery latency, and acknowledgement. Separately validate each policy condition with a safe synthetic signal, preview/evaluation data, or isolated zero-traffic revision; do not intentionally degrade the production hostname.
- [ ] Confirm normal readiness, latency, and error metrics are visible for the active revision and that logs correlate request, revision, build ID, and trace or request identifier where available.
- [ ] Define severity, acknowledgement target, escalation target, rollback decision point, false-positive handling, and maintenance procedure for each alert in `../../../operations/ROLLBACK_AND_OBSERVABILITY.md`.
- [ ] Verify log retention, release-evidence retention, Artifact Registry cleanup, current and previous known-good image availability, and monitoring configuration after the policy changes.[^platform-observability-retention]

## Exit criterion

All four policies are enabled and correctly scoped, every policy references the owned channel and current runbook, a human confirms test delivery, safe condition validation is recorded, and retention still protects the rollback window.

[^platform-observability]: [[../SedaiaPlatformBuildout/Phase 11 - Observability Capacity and Cost Controls#Ordered steps|Overall Platform Buildout Phase 11]] explicitly begins by completing these four policies and the acknowledged channel test, then extends their signals, dashboards, ownership, and runbooks across the full platform.
[^platform-observability-retention]: [[../SedaiaPlatformBuildout/Phase 11 - Observability Capacity and Cost Controls#Ordered steps|Overall Platform Buildout Phase 11]] owns cross-platform telemetry retention and capacity/cost controls; [[../SedaiaPlatformBuildout/Phase 12 - Backup Disaster Recovery and Runbooks#Ordered steps|Phase 12]] consumes the retained Cloud Run artifacts and evidence for recovery drills.
