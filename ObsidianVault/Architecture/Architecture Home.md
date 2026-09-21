---
tags:
  - architecture
  - map-of-content
aliases:
  - Platform Architecture
  - Architecture Wiki
status: current
reviewed: 2026-09-20
---

# Sedaia web platform architecture

This wiki describes the architecture implemented in the repository. It treats source and deployment configuration as authoritative, and labels future-facing configuration separately from live runtime behavior.

> [!summary]
> Sedaia is a monorepo containing two independently deployed static SolidJS sites and a versioned Kotlin/Ktor API. Vercel serves the sites; Google App Engine Standard serves the API. The public API contract is stored alongside the applications, but neither frontend currently consumes it.

## Start here

- [[System Context]] — users, domains, external platforms, and trust boundaries
- [[Runtime Topology]] — deployable units and request paths
- [[Ktor API]] — server startup, plugins, routes, and response models
- [[Frontend Applications]] — the portfolio and business-site architectures
- [[API Contract and Data Flow]] — OpenAPI, current data ownership, and integration status
- [[Build and Delivery]] — workspace tooling, CI, deployment, verification, and rollback
- [[Operations and Quality Attributes]] — availability, security controls, observability, and scaling
- [[Architecture Status and Evolution]] — implemented, scaffolded, stale, and unresolved elements
- [[Repository Map]] — ownership boundaries and high-value source locations

## Platform at a glance

```mermaid
flowchart LR
    visitor[Web visitor]
    operator[Release operator]
    portfolio[Portfolio static site<br/>SolidJS on Vercel]
    business[Business static SPA<br/>SolidJS Router on Vercel]
    api[Ktor API<br/>App Engine Standard]
    actions[GitHub Actions]

    visitor -->|sakura-sedaia.com| portfolio
    visitor -->|sedaia-designs.org| business
    visitor -. future browser fetch .->|api.sedaia-designs.org| api
    operator -->|manual protected workflow| actions
    actions -->|deploy immutable version| api
```

The dotted browser-to-API edge is an intended integration, not a current runtime dependency. Portfolio content is presently compiled into TSX, and the API returns an in-memory response with an empty project list.

## Architectural principles visible in the code

1. **Independent delivery.** Each application has its own build and hosting boundary.
2. **Static frontends by default.** Both SolidJS applications build to `dist/client` without a server runtime.
3. **Versioned public API.** Application routes live beneath `/v1`; health probes remain unversioned.
4. **Contract alongside implementation.** OpenAPI is a separate workspace concern and is linted independently.
5. **Protected production changes.** API deploy and rollback are manual, serialized, evidence-producing actions.
6. **Explicit origin access.** Ktor CORS allows only the production portfolio and business origins.

## Reading conventions

- **Current** means code or configuration is connected to an executable path.
- **Scaffolded** means dependencies or examples exist but are not part of the platform's active behavior.
- **Operational configuration** means the repository describes a production action, but repository inspection alone cannot prove hosted state.
- Source paths are repository-relative and intended to be searchable from the project root.

## Evidence baseline

This wiki was reviewed against the repository on 2026-09-20. Its primary API entry point is `../../apps/api/src/main/kotlin/org/sedaiadesign/api/routes/Api.kt`, followed through application startup, frontend composition, OpenAPI, build manifests, GitHub Actions, and operational scripts.
