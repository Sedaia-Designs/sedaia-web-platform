# Phase 12 - Backup Disaster Recovery and Runbooks

## Goal

Prove that data, artifacts, configuration, and deployments can be recovered within approved objectives and hand operators current procedures for incidents and routine care.

## Scope

Cloud SQL backups/PITR/restore, R2 independent copies/inventories, source/artifact/evidence retention, Vercel/Cloud Run/Worker rollback, DNS recovery, secret/key compromise, provider outage, runbooks, contacts, and disaster exercises.

## Prerequisites

Phases 03–11 implemented in staging, numeric RPO/RTO, retained known-good artifacts/deployments, and named incident commander/owners.

## Decisions before execution

Approve backup regions/providers, retention/legal holds, restore priority, disaster scenarios, evidence retention, fallback infrastructure criteria, and whether any cross-region database capability is post-launch.

## Repository areas and hosted systems

`operations/`, plan evidence, Cloud SQL, independent binary archive, R2, Cloud Run/Artifact Registry/evidence buckets, Vercel deployments, Cloudflare Worker/config, DNS/registrar, secrets/signing keys, source repository.

## Ordered steps

- [ ] Create concise runbooks for database restore/PITR and cutover, object restore/reconciliation, API rollback, Worker/config rollback, frontend rollback, DNS/certificate incident, signing/download key compromise, failed migration, compromised artifact withdrawal, alert triage, and provider outage.
- [ ] Inventory all recovery inputs and owners: source commits, lockfiles, container digests, migration history, database backups, object manifests/copies, signing material, Worker versions, Vercel deployments, DNS records, IaC/config, evidence, and contacts.
- [ ] Perform a clean non-production Cloud SQL restore/PITR, apply required IAM/database grants, run Flyway validate, query representative data, connect a test API, and measure RPO/RTO.
- [ ] Restore representative public/private binaries from the independent authority to a clean bucket, verify manifests/checksums/signatures/metadata, and serve them through an isolated test route.
- [ ] Drill Cloud Run immutable rollback under the remediation procedure, Worker rollback, independent Vercel rollback for both sites, and restoration to intended versions.
- [ ] Tabletop DNS/registrar/provider-account loss and credential/signing-key compromise, including revocation, rotation, cache/token expiry, and communications.
- [ ] Verify fallback infrastructure is not retired until its active plan’s exit criteria and observation window pass; specifically, App Engine retirement remains controlled by Cloud Run remediation Phase 05.
- [ ] Reconcile measured results with approved RPO/RTO; remediate or obtain explicit risk acceptance before publication.
- [ ] Publish operator handoff, review cadence, escalation tree, and evidence locations with no secrets embedded.

## Security and operational considerations

Backups need encryption, restricted access, retention, deletion controls, and restore testing. Recovery credentials must not depend on the failed provider/account alone. Avoid copying private data into lower-security test environments; use controlled restore projects and deletion evidence.

## Test strategy

Timed technical drills plus tabletop exercises, checksum/schema verification, access-negative tests, post-restore monitoring, rollback-and-restore-to-current, and reviewer observation.

## Acceptance criteria

Database and binary restores meet approved objectives; API/Worker/frontends roll back independently; DNS/account/key incidents have owned steps; fallback retirement criteria are respected; operators can find all recovery inputs.

## Evidence to retain

Backup/restore IDs, timestamps and measured RPO/RTO, schema/data/checksum validation, rollback deployment IDs, DNS/tabletop notes, key-rotation/revocation results, attendee approvals, residual risks, and next drill date.

## Rollback or recovery

This phase defines recovery. If a drill harms staging, restore its pre-drill versions/data from recorded checkpoints. Never perform a production destructive drill without separate explicit approval and a verified return path.

## Dependencies

Depends on Phases 03–11. Blocks production publication in Phase 13.

## Exit criterion

Observed recovery—not configuration alone—meets approved objectives for structured data, binary artifacts, API, Worker/CDN, both frontends, and provider/account operations.
