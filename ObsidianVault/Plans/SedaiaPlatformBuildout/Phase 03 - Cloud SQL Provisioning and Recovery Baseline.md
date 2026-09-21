# Phase 03 - Cloud SQL Provisioning and Recovery Baseline

## Goal

Provision a private, encrypted, observable, backed-up PostgreSQL foundation with verified Cloud Run connectivity and recovery controls.

## Scope

Cloud SQL PostgreSQL instances/databases, private networking, TLS, IAM database authentication, pooling limits, backups/PITR, HA/maintenance, monitoring, service identities, and the approved SQL hostname behavior.

## Prerequisites

Phases 01–02 complete, Cloud Run remediation constraints understood, approved RPO/RTO/tier/region, and rollback/change window.

## Decisions before execution

Confirm private IP/Direct VPC egress versus connector, HA tier, maintenance window/deny period, PITR/backup retention, IAM authentication mechanism and driver compatibility, pool size versus Cloud Run max instances/concurrency, and private DNS need.

## Repository areas and hosted systems

`apps/sql`, `apps/api`, API runtime configuration, infrastructure/configuration source selected by Phase 02, Cloud SQL, VPC/private services access or PSC, Secret Manager/IAM, Monitoring, DNS private zone if approved.

## Ordered steps

- [ ] Add reviewable infrastructure/configuration definitions and an operator checklist without embedding secrets.
- [ ] Create separate non-production and production databases/instances per the approved isolation model in the Cloud Run region.
- [ ] Enable private connectivity only, SSL enforcement, approved CA mode, deletion protection, backups, PITR, HA if approved, maintenance preferences, database flags, storage auto-growth/limits, and query insights/logging within privacy policy.
- [ ] Create separate migration and runtime database principals mapped to dedicated service identities where IAM database authentication is approved; remove default/shared application credentials.
- [ ] Grant schema-change rights only to the migration identity and minimal DML rights to runtime; document emergency owner access.
- [ ] Configure Cloud Run private egress and connection method without changing deployment gates or exposing the instance publicly.
- [ ] Calculate and enforce connection pool limits against Cloud Run maximum instances and PostgreSQL connection reserve; include retry/backoff and maintenance failover behavior.
- [ ] Configure backup/PITR, instance/connection/storage/CPU/memory/replication alerts, and maintenance notifications.
- [ ] Verify `sql.sedaia-designs.org` has no public A/AAAA/CNAME record or port exposure; if private DNS was approved, verify resolution only from authorized networks.
- [ ] Perform a non-production restore/PITR to a new instance, reconnect a test service, validate data, record time against RTO, and delete only after evidence review.

## Security and operational considerations

Never add `0.0.0.0/0` authorized networks or expose port 5432. IAM database auth still requires database grants and SSL. Pool tokens/connections must refresh safely. Audit privileged queries and access changes. Ensure restore projects also receive correct IAM database authorizations.

## Test strategy

Test authorized and unauthorized connections, TLS enforcement, private-only reachability, pool exhaustion behavior, maintenance/failover reconnect, backup visibility, PITR restore, deletion protection, monitoring signals, and public DNS/port negative checks.

## Acceptance criteria

Production PostgreSQL is private, encrypted, identity-bound, capacity-limited, backed up, monitored, and restore-tested; runtime cannot alter schema; migration identity is not used by requests; SQL hostname behavior matches the approved ADR.

## Evidence to retain

Redacted instance/network configuration, IAM/database grants, DNS lookup and port-negative tests, connection/pool test results, backup/PITR IDs, restore timestamps/data validation, alert IDs, maintenance settings, costs, and approvals.

## Rollback or recovery

Before application cutover, remove the new runtime binding and retain the instance for investigation. After use, favor application rollback compatible with the expanded schema; for corruption/data loss restore/PITR to a new instance, validate, then execute a reviewed cutover. Never assume a schema down-migration restores data.

## Dependencies

Depends on Phases 01–02. Phase 04 and persistence portions of Phase 07 depend on it. Cloud Run remediation remains the authority for release safety.

## Exit criterion

The approved application identity can perform only intended operations over the private encrypted path, unauthorized/public access fails, and a timed restore meets the approved recovery target.
