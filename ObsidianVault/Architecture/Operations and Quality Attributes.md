---
tags:
  - architecture
  - operations
  - quality-attributes
status: current
reviewed: 2026-09-20
---

# Operations and quality attributes

This note describes qualities supported by repository evidence and calls out where hosted configuration must still be verified.

## Availability and recoverability

- KHealth exposes liveness and readiness probes.
- Production smoke verification retries readiness for up to 60 seconds by default, then checks portfolio HTTP 200, JSON object shape, and portfolio-origin CORS.
- Deploys use immutable App Engine versions and verify 100% traffic allocation.
- Rollback reuses a provenance-checked existing version, avoiding rebuild drift.
- Frontend failures are isolated by application and provider project.

The readiness endpoint currently has no dependency checks, so it proves the Ktor process responds but not that a future database or downstream API is usable.

## Security boundaries

| Control | Implemented behavior | Limitation |
| --- | --- | --- |
| CORS allowlist | Four production HTTPS origins | CORS is not authentication |
| Cloud authentication | GitHub OIDC/Workload Identity | Hosted provider/service-account policy is external state |
| Production gate | Manual confirmation, `main`, environment, serialization | Strength depends on GitHub environment configuration |
| Secret handling | No application secrets or checked-in env file required | Future browser `VITE_` values are always public |
| Release provenance | GitHub run and manifest fields cross-checked | Evidence retained for only 30 days |

The API endpoints are intentionally public and declare no authentication scheme.

## Observability

Logback supplies application logging. Repository templates describe three Google Cloud alert policies:

- readiness unavailable after consecutive failures;
- HTTP 5xx ratio above 5% with a minimum traffic threshold;
- p95 request latency above two seconds for ten minutes.

The templates contain placeholder notification channels, owner values, and—in the readiness policy—an uptime-check ID. The runbook records monitoring setup and notification testing as pending. These files document intended controls; they do not prove the policies are installed or alerts reach an operator.

## Performance and scalability

- Both sites are static and suited to edge/CDN delivery through Vercel.
- Image files are emitted separately rather than embedded in JavaScript bundles.
- The portfolio delays collage activation with `IntersectionObserver`.
- The API is stateless, which permits horizontal instance scaling.

`app.yaml` does not set `automatic_scaling.max_instances`. The operations runbook explicitly leaves the cost/capacity limit unresolved. There is also no load test or declared latency budget beyond the proposed p95 alert threshold.

## Compatibility and maintainability

- API URL versioning creates a place for breaking-version separation.
- OpenAPI provides a language-neutral public contract.
- Kotlin response types are serialization-explicit.
- Application boundaries match deploy boundaries.
- Root catalogs centralize frontend and JVM versions.

Risks include prerelease SolidJS dependencies, no generated client, no contract-to-implementation test, hard-coded content duplication, and starter business-site code.

## Verification layers

| Layer | Current check |
| --- | --- |
| Kotlin unit/integration | Ktor test host route and CORS tests |
| Business component | Vitest counter interaction |
| Frontend static analysis | ESLint and production builds |
| Portfolio tests | Build and lint only |
| Contract | Redocly lint |
| Production API | Readiness, JSON object, CORS, App Engine resource/traffic checks |
| Monitoring | Templates and manual runbook evidence |

## Source evidence

- Health and CORS: `../../apps/api/src/main/kotlin/org/sedaiadesign/api/lib/plugins`
- Test coverage: `../../apps/api/src/test/kotlin/org/sedaiadesign/api/ServerTest.kt`, `apps/business/src/components/Counter.test.tsx`
- Smoke verification: `../../scripts/verify-api-deployment.sh`
- Monitoring: `../../operations/monitoring`
- Operational status: `../../operations/ROLLBACK_AND_OBSERVABILITY.md`
