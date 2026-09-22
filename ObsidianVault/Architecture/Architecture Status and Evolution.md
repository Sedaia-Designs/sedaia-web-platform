---
tags:
  - architecture
  - status
  - technical-debt
status: current
reviewed: 2026-09-19
---

# Architecture status and evolution

This page prevents planned architecture from being mistaken for implemented architecture.

## Capability status

| Capability | Status | Evidence |
| --- | --- | --- |
| Static portfolio | Implemented | Domain content and interactions in portfolio TSX |
| Routed business SPA shell | Implemented | File routes, typed paths, Vercel rewrite |
| Finished business website | Not implemented | Source remains Solid starter/demo content |
| Versioned public API | Implemented | `/v1` and `/v1/portfolio/content` routes |
| API-backed portfolio | Planned/scaffolded | CORS, OpenAPI, and env documentation exist; no client call |
| API persistence | Scaffolded only | Database dependencies exist; no connection or repository code |
| Generated TypeScript API client | Not implemented | Only `openapi.yaml` exists in package directory |
| API CI | Implemented | Gradle check job |
| Frontend CI | Implemented | Lint/test/build jobs |
| Protected API deploy/rollback | Repository implementation complete | Workflows and scripts exist; hosted controls require verification |
| Frontend deployment automation | External/unclear | Vercel configs exist; Git deployment disabled; no Actions workflow |
| Production monitoring | Partially prepared | Templates exist; runbook marks setup evidence pending |

## Notable inconsistencies

### OpenAPI trailing slash

The portfolio content contract is canonicalized at `/v1/portfolio/content` across implementation tests, OpenAPI, deployment checks, and architecture documentation.

### CI documentation drift

The README describes active path-filtered GitLab CI and references `.gitlab-ci.yml`; the active tree contains GitHub workflows and only an ignored legacy GitLab reference area. The architecture follows executable GitHub configuration.

### Cloud Run artifact versus App Engine deployment

The root Dockerfile describes a Cloud Run container path, while current workflows, runbooks, Gradle configuration, and monitoring all target App Engine Standard. Maintaining both without a stated purpose increases ambiguity.

### Database dependencies without persistence

Exposed, R2DBC, and H2 are declared but unused. They can mislead maintainers into assuming stateful behavior or readiness coverage that does not exist.

### StatusPages dependency without plugin installation

`ktor-server-status-pages` is present, but there is no `install(StatusPages)`. The contract's generic 500 response has no explicit application error format.

## Evolution seams

The current system provides clean extension points:

- add an API service/repository layer behind `apiRoutes()`;
- connect readiness checks to real dependencies when introduced;
- generate a typed client from OpenAPI under `../../packages/api-client`;
- add a portfolio data adapter driven by `VITE_API_BASE_URL`;
- migrate hard-coded TSX content incrementally while retaining static fallbacks;
- replace business demo routes within the existing typed route shell;
- add contract response validation to CI and deployment smoke tests.

## Suggested decision records

Future changes would benefit from explicit ADRs for:

1. canonical API path/trailing-slash policy;
2. production persistence technology and ownership;
3. whether Cloud Run/container support remains a supported target;
4. frontend deployment trigger and promotion policy;
5. generated API-client strategy and compatibility rules;
6. App Engine maximum instance/cost limit;
7. client-side SPA versus SSR for the business site's SEO and HTTP-status needs.

These are suggested documentation topics, not approved decisions or an execution plan.

## Review triggers

Review this wiki when any of the following changes:

- a frontend starts calling the API;
- a database or authentication mechanism is added;
- Vercel deployment automation changes;
- the API moves away from App Engine;
- routes or OpenAPI schemas change;
- monitoring templates are installed and verified;
- SolidJS leaves prerelease versions or SSR is enabled.
