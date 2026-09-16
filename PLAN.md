# Sedaia Designs Monorepo Plan

## Purpose

This repository will be rebuilt as a blank monorepo for two related domains:

- [`sedaia-designs.org`](https://sedaia-designs.org) is the business and platform domain. It owns the central website, API, documentation, blog, and public asset/CDN surface.
- [`sakura-sedaia.com`](https://sakura-sedaia.com) is the personal portfolio. It contains one SolidJS application and consumes portfolio services from the Sedaia Designs API when dynamic behavior is required.

The monorepo is a source-control and coordination boundary, not a single deployable application. Every public application must remain independently buildable and deployable.

The repository is hosted in the **Sedaia Designs** GitLab group. Repository remotes use this form:

```text
https://gitlab.com/sedaia-designs/repository
```

## Domain and Hosting Map

| Public address                | Responsibility                      | Runtime/host                                           |
|-------------------------------|-------------------------------------|--------------------------------------------------------|
| `sedaia-designs.org`          | Business website                    | SolidJS on Vercel                                      |
| `docs.sedaia-designs.org`     | Product and developer documentation | Vercel                                                 |
| `blog.sedaia-designs.org`     | Blog and long-form content          | Vercel                                                 |
| `cdn.sedaia-designs.org`      | Versioned public assets             | Vercel-compatible static or object storage/CDN service |
| `api.sedaia-designs.org/v1/*` | Public backend API                  | Ktor on Google Cloud Run                               |
| `sakura-sedaia.com`           | Personal portfolio                  | SolidJS on Vercel                                      |

The canonical portfolio API will be:

```text
https://api.sedaia-designs.org/v1/portfolio
```

`sedaia-designs.org/api/*` will not be a second public API contract. It may be introduced later only as a transparent proxy if a same-origin route has a demonstrated benefit.

## Technology Baseline

- API: Kotlin/JVM with Ktor
- Frontends: SolidJS v2
- JVM: Java 21
- JavaScript runtime: Node.js 22.18
- Package manager: pnpm 10.22
- JVM build: Gradle 9.5.1 using the Gradle Wrapper
- Frontend hosting: Vercel
- API hosting: Google Cloud Run
- API description: OpenAPI, used to document the service and produce or validate the TypeScript client

Versions are the intended rebuild baseline. They should be centralized in the Gradle version catalog, wrapper configuration, and root package-manager metadata rather than repeated across modules.

References:

- Business-site/API starting point: <https://gitlab.com/sedaia-designs/ktor-solidjs-template>
- Existing portfolio source: <https://gitlab.com/SakuraSedaia/sedaia-portfolio>

The references are migration inputs, not directories to copy wholesale. Only intentional application code, content, assets, tests, and configuration should be brought into the new structure.

## Proposed Repository Structure

```text
.
├── apps/
│   ├── api/                 # Ktor service; Gradle module; deployed to Cloud Run
│   ├── business-site/       # sedaia-designs.org; deployed to Vercel
│   ├── portfolio/           # sakura-sedaia.com; deployed to Vercel
│   ├── docs/                # docs.sedaia-designs.org; deployed to Vercel
│   └── blog/                # blog.sedaia-designs.org; deployed to Vercel
├── packages/
│   ├── api-client/          # Typed TypeScript API client/contracts
│   ├── design-tokens/       # Shared colors, typography, spacing, and other tokens
│   └── shared-config/       # Shared frontend tooling configuration where useful
├── infrastructure/
│   ├── cloud-run/           # API deployment configuration
│   └── vercel/              # Shared deployment notes/configuration
├── buildSrc/                # Gradle convention plugins for JVM modules
├── gradle/
├── package.json             # Root scripts and pnpm workspace entry point
├── pnpm-workspace.yaml
├── settings.gradle.kts
└── PLAN.md
```

Do not retain generic modules such as `app` and `utils`. Modules and packages should be named after their responsibility. Code should be shared only after at least two consumers require the same behavior; the blank template should not begin with speculative utility packages.

## Build and Workspace Model

Gradle owns Kotlin/JVM compilation, testing, packaging, and API container preparation. pnpm workspaces own JavaScript/TypeScript applications and shared packages. Node applications should not be modeled as Gradle subprojects merely to create a single build system.

The root should expose a small, consistent command surface for:

- installing frontend dependencies;
- building, testing, linting, and formatting all projects;
- running the API and individual frontends locally;
- validating the OpenAPI document and generated client;
- building the API container; and
- checking the complete repository in CI.

Each application must also retain standalone commands so it can be built and deployed without running unrelated applications.

## API and Cloud Run Contract

The Ktor service will run as a stateless Cloud Run service. It must:

- listen on `0.0.0.0` and use the `PORT` environment variable, with `8080` as the local default;
- terminate TLS at Google Cloud rather than inside Ktor;
- write structured application logs to standard output/error;
- provide lightweight liveness and readiness endpoints;
- store persistent data outside the container filesystem;
- use environment variables or Google Secret Manager for runtime configuration and secrets;
- handle graceful shutdown; and
- constrain instance scaling based on downstream database connection limits.

Initial Cloud Run settings:

- request-based billing;
- minimum instances set to `0`;
- startup CPU boost enabled;
- an explicit maximum-instance limit;
- API and data services located in the same Google Cloud region; and
- public unauthenticated ingress only for explicitly public API routes.

If cold-start latency becomes unacceptable, the first operational change will be setting the minimum instance count to `1`. A custom GraalVM/native build is not part of the initial template.

Development and staging may use the generated `*.run.app` address. Production `api.sedaia-designs.org` should ultimately use Google Cloud's supported custom-domain path through an external Application Load Balancer. A temporary Vercel reverse proxy may be used during early deployment, but it should not become a permanent dependency for API availability.

## Frontend and Vercel Model

Each frontend directory will be connected to its own Vercel project with its own root directory, environment variables, preview deployments, and production domain. Deployments should use affected-project filtering so an unrelated change does not rebuild every site.

Frontend applications receive the API origin through environment configuration:

```text
Development: local Ktor address
Preview: stable staging API address
Production: https://api.sedaia-designs.org
```

The portfolio should remain useful during an API outage. Content required for its initial render should be static, generated at build time, or cached where practical. The runtime API should be reserved for behavior that is genuinely dynamic.

## API Boundaries and Browser Security

The API will be versioned under `/v1`. Breaking changes require a new major path rather than silently changing existing response shapes.

Production CORS configuration must explicitly allow the intended web origins, initially:

```text
https://sakura-sedaia.com
https://www.sakura-sedaia.com
https://sedaia-designs.org
```

Wildcard origins must not be used for credentialed or authenticated endpoints. Vercel preview deployments should use either an explicit preview-origin policy or a frontend proxy; production CORS must not be opened broadly to accommodate previews.

OpenAPI is the source of truth for public HTTP operations and data shapes. The TypeScript client should be generated from it or checked against it in CI so Kotlin and frontend contracts cannot drift unnoticed.

## CDN and Assets

`cdn.sedaia-designs.org` is a public delivery surface, not necessarily a continuously running application. Its implementation should be selected when storage requirements are known.

Regardless of provider, public assets should:

- use content-hashed or explicitly versioned paths;
- be immutable once published at a versioned URL;
- use long-lived cache headers for immutable files;
- avoid storing private or user-specific content; and
- have a documented publication process.

Static assets that belong to only one site should remain within that site's deployment instead of being moved into the shared CDN automatically.

## CI/CD and Environments

The repository will have three logical environments:

- local development;
- preview/staging; and
- production.

CI must run affected builds where possible, plus contract checks when either the API schema or API client changes. Production deployment responsibilities are split:

- Vercel deploys each frontend from its application directory.
- Google Cloud builds and deploys the API container to Cloud Run.
- Production API deployment runs only after JVM tests and container validation pass.
- Database migrations, if introduced, run as an explicit deployment step or Cloud Run job, never implicitly on every application instance startup.

Secrets must not be committed. Vercel environment variables manage frontend/server-side web configuration, while Google Secret Manager or protected Cloud Run environment configuration manages API secrets.

## Blank-Template Rebuild Sequence

1. Preserve this plan, required legal files, and any repository-level documentation.
2. Remove the generated `app` and `utils` sample modules and other disposable starter content.
3. Establish the root Gradle build, pnpm workspace, shared formatting rules, and CI entry points.
4. Create a minimal Ktor API with health endpoints, OpenAPI generation or publication, tests, and a Cloud Run-compatible container.
5. Create minimal deployable shells for the business site, portfolio, docs, and blog.
6. Connect each frontend to a separate Vercel project and deploy the API to a non-production Cloud Run service.
7. Import the existing portfolio and template code selectively, preserving behavior through tests rather than preserving the old directory structure.
8. Add the typed API client and wire the portfolio to the staging API.
9. Configure production domains, CORS, secrets, monitoring, and deployment protections.
10. Introduce CDN storage only when the first shared asset use case is defined.

## Initial Acceptance Criteria

The blank template is ready for application migration when:

- a fresh checkout can install and validate both Gradle and pnpm workspaces using documented commands;
- every application builds independently;
- the API test suite passes and its container starts locally on a configurable port;
- `/health/live`, `/health/ready`, and the initial `/v1/portfolio` contract are testable;
- each frontend has an isolated Vercel project configuration and preview deployment;
- the staging portfolio can call the staging Cloud Run API under the intended CORS policy;
- API contract drift fails CI;
- no secrets or machine-specific IDE state are required to build the repository; and
- deployment or failure of one application does not require deployment of the others.

## Deferred Decisions

The following choices should be made when their requirements are known rather than guessed during scaffolding:

- database engine and migration tool;
- authentication and authorization model;
- documentation and blog frameworks;
- CMS or Git-based content workflow;
- CDN/object-storage provider;
- observability beyond baseline Cloud Logging and Vercel logs; and
- whether preview deployments require per-branch API environments.
