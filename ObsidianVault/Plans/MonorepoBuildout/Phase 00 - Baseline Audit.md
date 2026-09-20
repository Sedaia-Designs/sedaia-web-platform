# Phase 00 - Baseline Audit

**Status: Complete (repository audit 2026-09-17).**

Confirmed present:

- Gradle and pnpm workspace roots;
- independently scoped `apps/api`, `apps/business`, and `apps/portfolio`;
- Ktor health and portfolio endpoints with tests;
- Cloud Run container and deployment configuration;
- isolated Vercel configuration for both current frontends; and
- the public OpenAPI contract under `packages/api-client`.

Confirmed absent or incomplete:

- `apps/docs` and `apps/blog`;
- generated API-client code;
- `packages/design-tokens` and `packages/shared-config`;
- a selected shared CDN implementation; and
- a runtime Portfolio API consumer.

Exit criterion: repository reality is recorded without treating deferred
requirements as completed features.
