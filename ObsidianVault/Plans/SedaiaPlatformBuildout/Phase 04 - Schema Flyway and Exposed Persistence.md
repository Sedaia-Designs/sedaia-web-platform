# Phase 04 - Schema Flyway and Exposed Persistence

## Goal

Create the structured-data model, immutable migration history, Exposed persistence layer, transaction boundaries, seed/import process, and compatibility rules.

## Scope

Products, releases, artifacts, compatibility, licenses, media, checksums, object keys, publication/approval state, audit data, constraints, Flyway, PostgreSQL driver, Exposed, fixtures, and deployment ordering.

## Prerequisites

Approved product/entity decisions, Phase 03 non-production database, data classification, and migration/runtime identities.

## Decisions before execution

Approve identifiers/slugs, version semantics, compatibility taxonomy, artifact cardinality, checksum representation, audit/soft-delete requirements, seed authority, JDBC versus R2DBC. The current API declares Exposed R2DBC and H2; confirm PostgreSQL R2DBC maturity and pooling/auth compatibility or deliberately choose JDBC with bounded dispatching and pooling.

## Repository areas and hosted systems

`apps/sql`, `apps/api/build.gradle.kts`, new API persistence modules/tests, Flyway migration resources/tasks, `packages/api-client`, non-production and production Cloud SQL.

## Ordered steps

- [ ] Model normalized tables and ownership for product, release, compatibility, license, artifact, media, publication, checksum, object key, approval/audit, and optional entitlement references.
- [ ] Enforce unique immutable object keys, SHA-256 format, non-negative size, allowed states, version uniqueness, and foreign keys so published metadata cannot reference a missing/invalid artifact row.
- [ ] Keep physical object existence verification in the publication workflow because PostgreSQL cannot enforce an R2 object constraint.
- [ ] Add pinned PostgreSQL driver, Flyway, and the single selected Exposed transport; remove H2 from production dependencies and keep it only if tests prove dialect parity needs.
- [ ] Create versioned Flyway migrations in one authoritative location, baseline rules, naming convention, checksum validation, repeatable-data policy, and separate environment configuration.
- [ ] Build Exposed table mappings, repository interfaces, and service transaction boundaries; keep HTTP parsing, object-storage calls, and long-running scans outside database transactions.
- [ ] Use read-only transactions for queries where supported and idempotency keys/optimistic locking for publication commands.
- [ ] Create minimal deterministic seed/reference data and an import manifest for legacy content; never make application startup mutate schema or seed production.
- [ ] Test expand/migrate/deploy/contract sequencing and define contract cleanup only after all consumers and rollback versions are beyond the old schema.
- [ ] Define failure handling: Flyway validate before migrate, backup/recovery checkpoint, one migration job/identity, evidence capture, and roll-forward-first response.

## Security and operational considerations

Avoid sensitive tokens in tables/logs. Constrain free-form metadata. Parameterize queries through Exposed. Use database constraints as defense in depth. Do not edit an applied migration; add a new migration. Separate personally identifying audit fields according to retention policy.

## Test strategy

Run migrations from empty and prior supported schemas on PostgreSQL, Flyway validate, repository integration tests, constraint/transaction/concurrency/idempotency tests, dialect-specific queries, seed/import dry run, compatibility tests with current and candidate API revisions, and a destructive-change recovery rehearsal in non-production.

## Acceptance criteria

Schema and Exposed mappings express approved ownership; production startup never migrates; migration and runtime privileges differ; migrations are repeatable from supported baselines and backward-compatible across the release window; seed/import output is reconciled.

## Evidence to retain

ERD/ADR, migration files/checksums and Flyway output, schema version, grants, integration results, import manifest/reconciliation, compatibility matrix, backup checkpoint, migration job ID/log, and reviewer approval.

## Rollback or recovery

Prefer application rollback against compatible expanded schema or a corrective forward migration. For irreversible/data-loss failure, restore/PITR to a new instance and execute a reviewed cutover. Record why and when any undo script is safe; never treat it as backup.

## Dependencies

Depends on Phases 01 and 03. Blocks persistence API work, metadata publication, and final data migration.

## Exit criterion

A clean PostgreSQL database can be migrated, seeded/imported, queried through tested Exposed repositories, and advanced safely while current and candidate application versions remain compatible.
