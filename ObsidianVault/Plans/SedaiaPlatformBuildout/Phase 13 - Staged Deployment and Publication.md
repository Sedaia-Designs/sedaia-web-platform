# Phase 13 - Staged Deployment and Publication

## Goal

Execute a controlled, reversible, cross-component production release without exposing unverified candidates or violating component authority.

## Scope

Release freeze, evidence, migrations, assets, API, Worker/CDN, metadata publication, Vercel staged deployments, DNS/TLS, monitoring, rollback checkpoints, observation, and communications.

## Prerequisites

Phases 00–12 complete, Cloud Run remediation production gates complete, approved change window and owners, known-good rollback targets, fresh backups, and no unresolved release blockers.

## Decisions before execution

Approve exact commit/artifact/migration/asset versions, maintenance/publication window, go/no-go owners, rollback thresholds, DNS TTL schedule, customer communication, and observation period.

## Repository areas and hosted systems

All deployable source/configuration, GitHub/Cloud Build, Cloud SQL, Cloud Run, Artifact Registry, Cloudflare R2/Worker/CDN/Images/DNS, Vercel projects/domains, monitoring/incident channels, evidence stores.

## Ordered steps

- [ ] Record release manifest with reviewed commit, dependency locks, image/Worker/frontend build IDs, Flyway target, asset manifests/checksums, owners, approvals, known-good targets, and incident channel.
- [ ] Verify backups/PITR, independent binary copies, evidence retention, alerts/channels, credentials, quotas, certificates, DNS rollback records, and provider status.
- [ ] Run all locked CI/security/contract/accessibility checks and build immutable candidates; stop on any unapproved exception.
- [ ] Run Flyway validate and apply only approved backward-compatible migrations with the migration identity; retain before/after schema/evidence and verify current API compatibility.
- [ ] Upload/scan/sign/approve assets and verify production object/header behavior while metadata remains unpublished.
- [ ] Deploy the API exclusively through Cloud Run remediation; verify exact zero-traffic candidate, schema compatibility, canonical endpoint, alerts, and recovery evidence.
- [ ] Deploy/verify the retained Worker/CDN candidate and confirm private bypass remains impossible.
- [ ] Create unpublished product/release rows, reconcile every database object key/checksum with R2 and independent archive, then atomically publish metadata.
- [ ] Create exact staged Vercel production deployments for Portfolio and Business with production environment configuration and no automatic custom-domain assignment; execute Phase 08/09 gates against staged URLs.
- [ ] Promote one frontend at a time, verify domain/TLS/API/CDN/monitoring, then promote the other; do not couple their rollback.
- [ ] Apply/confirm asset and approved SQL DNS behavior, TLS, DNSSEC/records, TTLs, and external resolution. SQL must remain non-public.
- [ ] Run immediate smoke/security/accessibility-critical checks, watch alerts/cost/capacity through the approved window, and invoke the predefined rollback threshold without improvising unsafe fixes.
- [ ] Freeze evidence, publish operator/status documentation, and proceed to Phase 14; do not restore automatic Portfolio deployment here.

## Security and operational considerations

Use two-person review for production migration/publication where available. Keep credentials short-lived. Do not bypass failed scans, CORS, private access, or alerts to meet a window. Avoid destructive cleanup until observation and rollback compatibility expire.

## Test strategy

Run component smoke/contract/E2E tests at exact candidate and canonical endpoints, public/private negative tests, TLS/DNS checks, DB schema/data reconciliation, asset checksum/header/range tests, frontend critical accessibility checks, alert correlation, and known-good rollback readiness checks.

## Acceptance criteria

All components are deployed from the release manifest in the required order; only verified candidates receive traffic; metadata references verified immutable objects; both sites are independently promoted; SQL remains private; alerts are quiet/healthy or explained; complete evidence is retained.

## Evidence to retain

Release manifest and approvals, commit/digests/build/deployment/revision IDs, Flyway output/schema version, backup/PITR checkpoint, object/scan/sign/inventory manifests, DNS/TLS before/after, Vercel promotions, monitoring snapshots/alerts, smoke/E2E results, and any rollback/incident record.

## Rollback or recovery

Stop publication and follow component-specific procedures: revert metadata state, restore prior Worker, route Cloud Run to verified revision if schema-compatible, reassign each Vercel domain independently, restore DNS records, revoke grants/keys, or restore/PITR according to runbooks. Prefer roll-forward for schema; never overwrite immutable assets.

## Dependencies

Depends on Phases 00–12 and Cloud Run remediation completion. Phase 14 must run last.

## Exit criterion

The complete release is live on intended production routes with no known blocker, all rollback targets intact, and sufficient retained evidence for independent final acceptance.
