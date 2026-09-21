# Sedaia Designs Persistence Placeholder

## Current Status

This directory reserves the future SQL persistence application and its migration assets. There is no active runtime database. The Ktor API is stateless and currently constructs portfolio and contact content directly in its route implementation. Exposed, R2DBC, and H2 dependencies are scaffolded but are not connected or configured as a persistence architecture.

## Intended Responsibility

The database may eventually store structured portfolio content, contact metadata, render metadata, and references to immutable public assets delivered by the shared CDN. Binary asset files belong in object storage rather than SQL; the database should store their identifiers, locations, metadata, and relationships.

## Implementation Requirements

- Select the SQL engine and migration tool from documented production requirements before adding schemas.
- Keep database entities and persistence models separate from the API's public transport models.
- Apply versioned migrations as an explicit deployment step or dedicated job, never implicitly from every API instance at startup.
- Configure connection limits, secrets, backups, recovery, least-privilege identities, and environment isolation before production use.
- Extend readiness checks to cover required database connectivity only after the API actually depends on the database.
- Migrate existing hard-coded content through a reviewed data migration without inventing placeholder production records.

## Activation Criterion

Replace this placeholder when the persistence engine, schema ownership, migration workflow, and first API-backed data use case have been reviewed and implemented.
