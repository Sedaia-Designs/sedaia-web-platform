---
tags:
  - architecture
  - backend
  - ktor
status: current
reviewed: 2026-09-19
---

# Ktor API

The API is a small stateless Ktor application. [[Runtime Topology]] explains its hosting boundary; this note follows its internal control flow.

## Startup and composition

```mermaid
flowchart TD
    main[main(args)] --> engine[Netty EngineMain]
    yaml[application.yaml] --> engine
    engine --> module[Application.module]
    module --> configure[configureServerPlugins]
    configure --> cors[configureCors]
    configure --> serialization[configureSerialization]
    configure --> health[configureKHealth]
    module --> v1[route /v1]
    v1 --> apiRoutes[apiRoutes]
```

Responsibilities are deliberately shallow:

- `main.kt` delegates to Ktor's `EngineMain`.
- `application.yaml` selects the module and runtime port.
- `Module.kt` is the composition root.
- `ConfigureServerPlugins.kt` centralizes cross-cutting plugin installation.
- `Api.kt` defines the versioned route tree.

## Route catalog

| Method and path | Owner | Response | Notes |
| --- | --- | --- | --- |
| `GET /health/live` | KHealth plugin | `{}` JSON, HTTP 200 | Process liveness |
| `GET /health/ready` | KHealth plugin | `{}` JSON, HTTP 200 | Readiness with no downstream checks |
| `GET /v1` | `apiRoutes()` | `ApiMetadataResponse` JSON | Version-root metadata endpoint |
| `GET /v1/portfolio/content` | `apiRoutes()` | `PortfolioResponse` JSON | Empty programming collection pending persistence |

The implementation, tests, OpenAPI contract, and deployment smoke checks use `/v1/portfolio/content` as the canonical content-delivery path.

## Serialization model

`ContentNegotiation` installs Kotlinx JSON with default settings. Two `@Serializable` response types form the public model:

```text
PortfolioResponse
├── programming: List<ProgrammingResponse>
    ├── title: String
    ├── description: String
    ├── projectPage: String
    ├── sourceCode: String
    └── documentation: String?
└── contact: List<ContactResponse>
    ├── type: [ContactType](../../apps/api/src/main/kotlin/org/sedaiadesign/api/models/types/ContactType.kt)
    ├── label: String
    ├── icon: ContactIconType
    ├── value: String
    └── href: String
```

There is no domain or persistence layer between routing and response construction. That is proportionate to the current static response, but future persistence should keep transport models separate from database models.

## Cross-origin behavior

The CORS plugin allows HTTPS requests from:

- `sakura-sedaia.com`
- `www.sakura-sedaia.com`
- `sedaia-designs.org`
- `www.sedaia-designs.org`

Tests prove that the portfolio origin receives `Access-Control-Allow-Origin` and an unknown origin receives HTTP 403. This is browser access policy, not caller authentication or authorization.

## Dependencies: active and dormant

Active runtime concerns include Netty, YAML configuration, CORS, content negotiation, Kotlinx serialization, Logback, and KHealth.

The build also declares Exposed core/R2DBC, H2, and R2DBC H2. No source imports or config connect them, so the API is currently stateless and these are **scaffolded database dependencies**, not an active persistence architecture.

`ktor-server-status-pages` is also declared but no StatusPages plugin is installed. Unhandled-error response shaping is therefore not explicitly defined by application code.

## Tests

`ServerTest.kt` exercises the application in Ktor's test host and covers:

- both health endpoints and their JSON content type;
- the versioned root;
- portfolio HTTP status, JSON content type, and current programming titles;
- allowed production portfolio CORS origin;
- rejection of an unknown origin.

The tests do not validate the complete portfolio response against OpenAPI, test a business-site origin, or exercise failure/status-page behavior.

## Source evidence

- Route entry point: `../../apps/api/src/main/kotlin/org/sedaiadesign/api/routes/Api.kt`
- Composition root: `../../apps/api/src/main/kotlin/org/sedaiadesign/api/Module.kt`
- Plugins: `../../apps/api/src/main/kotlin/org/sedaiadesign/api/lib/plugins`
- Response DTOs: `../../apps/api/src/main/kotlin/org/sedaiadesign/api/models/response`
- Build dependencies: `../../apps/api/build.gradle.kts`
- Tests: `../../apps/api/src/test/kotlin/org/sedaiadesign/api/ServerTest.kt`
