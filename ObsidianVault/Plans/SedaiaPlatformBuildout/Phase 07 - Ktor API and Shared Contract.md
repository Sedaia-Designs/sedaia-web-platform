# Phase 07 - Ktor API and Shared Contract

## Goal

Evolve the Ktor API from hard-coded portfolio data to backward-compatible persistence and release/catalog contracts with clear health, errors, authentication, rate controls, and shared-client guarantees.

## Scope

Routes/models/OpenAPI, service/repository layers, database integration, restricted-download grants, health/readiness, errors, validation, CORS, authentication boundaries, rate limiting, pagination, generated/shared client, and Cloud Run compatibility.

## Prerequisites

Phases 03–06 contracts available, Cloud Run remediation Phase 01 contract rules honored, and product API requirements approved.

## Decisions before execution

Approve endpoint/resource shapes, versioning/pagination/filtering, public versus operator endpoints, error envelope, readiness dependency policy, download-grant protocol, rate-limit keys/thresholds, and generated-client choice.

## Repository areas and hosted systems

`apps/api`, `packages/api-client/openapi.yaml`, potential generated client files, scripts/tests, `cloudbuild.yaml`, Cloud Run, Cloud SQL, Cloudflare Worker.

## Ordered steps

- [ ] Design backward-compatible `/v1` catalog/product/release/media/download operations and precise OpenAPI schemas/examples/errors; do not silently repurpose existing portfolio fields.
- [ ] Introduce route-service-repository separation and Exposed transactions from Phase 04; enforce published-only filtering for public endpoints and authorized commands for state changes.
- [ ] Replace hard-coded data only after seed/import reconciliation and preserve a tested fallback or deployment order that keeps current portfolio behavior compatible.
- [ ] Implement a consistent error envelope and StatusPages handling without leaking stack traces, SQL details, tokens, or object internals.
- [ ] Make liveness process-only; make readiness fail only for dependencies required to serve the intended traffic, with bounded timeouts and clear degraded-state policy.
- [ ] Add restricted-download authorization that checks publication, artifact state, entitlement if required, expiry, and object binding before issuing a short-lived Worker grant; never proxy public binaries through Ktor.
- [ ] Enforce input bounds, pagination maxima, request/body limits, CORS allowlists, and provider/application rate controls; define trusted proxy/client IP handling.
- [ ] Decide and implement either pinned OpenAPI client generation with deterministic drift checks or typed handwritten adapters with equivalent contract tests; document consumer upgrade rules.
- [ ] Extend unit, PostgreSQL integration, contract, security-negative, deployment-verifier, and rollback-compatibility tests.
- [ ] Integrate deployment only through Cloud Run remediation’s zero-traffic candidate, exact-revision verification, named promotion, evidence, and recovery process.

## Security and operational considerations

Public read endpoints and restricted authorization have different abuse risks. Deny unpublished/private records by default. Rotate signing keys with overlap and `kid`. Bound database queries and timeouts. Avoid making readiness flap on optional Cloudflare dependencies.

## Test strategy

Test OpenAPI/implementation/client agreement, current-old and candidate-new consumer compatibility, PostgreSQL failures/timeouts, malformed/oversized inputs, unpublished access, authorization tampering/expiry, CORS allow/deny, rate limits, error redaction, probes, zero-traffic deployment, and immutable rollback.

## Acceptance criteria

Contracts, Kotlin models, persistence, client/adapters, smoke tests, and evidence schema agree; the API remains backward-compatible through rollout; restricted grants are narrow and short-lived; Cloud Run remediation passes in full before production use.

## Evidence to retain

OpenAPI diff/version, generated-client provenance if applicable, test reports, schema version, migration/API compatibility matrix, load/rate results, key-rotation test, Cloud Build/revision/digest evidence, canonical verification, alerts, and rollback drill.

## Rollback or recovery

Route traffic to the previous verified Cloud Run revision only if it remains schema-compatible. Revoke download-signing keys or disable grant issuance during compromise. Roll forward schema fixes or invoke Phase 03 restore procedures for data loss.

## Dependencies

Depends on Phases 03–06. Cloud Run remediation is a hard external gate. Phases 08–09 consume this contract; Phase 13 publishes it.

## Exit criterion

The exact production candidate serves approved data and authorization contracts from PostgreSQL, passes all negative and dependency tests at zero traffic, and has a verified compatible rollback.
