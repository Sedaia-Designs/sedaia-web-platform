---
tags:
  - architecture
  - repository
status: current
reviewed: 2026-09-20
---

# Repository map

Use this map to find architectural responsibility quickly.

```text
sedaia-designs/
├── apps/
│   ├── api/                 Kotlin/Ktor API and App Engine descriptor
│   ├── business/            Routed SolidJS business SPA
│   └── portfolio/           Single-page SolidJS portfolio
├── packages/
│   └── api-client/          OpenAPI contract; no generated client yet
├── scripts/                 API release, verification, and rollback scripts
├── operations/              API runbook and monitoring policy templates
├── .github/workflows/       CI, API deploy, and API rollback
├── gradle/                  JVM version catalog and wrapper
├── ObsidianNotes/           Repository notes required by project guidance
├── package.json             pnpm orchestration and contract lint command
├── pnpm-workspace.yaml      frontend/package membership and version catalogs
├── settings.gradle.kts      Gradle repositories and API project inclusion
├── build.gradle.kts         shared JVM conventions
└── Dockerfile               currently unconnected container build path
```

## Ownership boundaries

| Path | Primary responsibility | Change impact |
| --- | --- | --- |
| `../../apps/api` | Public API | JVM build and API deployment |
| `../../apps/business` | Business web experience | Business Vercel artifact |
| `../../apps/portfolio` | Personal portfolio experience | Portfolio Vercel artifact |
| `../../packages/api-client` | Public API compatibility contract | Contract consumers and API implementation |
| root pnpm files | Frontend dependency/workspace policy | Both frontends and contract tooling |
| root Gradle files | JVM toolchain/dependency policy | API |
| `../../.github/workflows` | Validation and production control plane | Repository and API operations |
| `operations`, `scripts` | Runtime verification and recovery | Production API operations |

## High-value entry points

| Question | Start with |
| --- | --- |
| What does the API expose? | `../../apps/api/src/main/kotlin/org/sedaiadesign/api/routes/Api.kt` |
| How does Ktor start? | `../../apps/api/src/main/kotlin/org/sedaiadesign/api/Module.kt`, `apps/api/src/main/resources/application.yaml` |
| Which browser origins are allowed? | `../../apps/api/src/main/kotlin/org/sedaiadesign/api/lib/plugins/CorsPlugin.kt` |
| What is the public API contract? | `../../packages/api-client/openapi.yaml` |
| How is the portfolio composed? | `../../apps/portfolio/src/App.tsx` |
| How does business routing work? | `../../apps/business/src/router.ts`, `src/routes/` |
| What is validated in CI? | `../../.github/workflows/ci.yml` |
| How is the API deployed? | `../../.github/workflows/deploy-api.yml` |
| How is an API release restored? | `../../.github/workflows/rollback-api.yml`, `scripts/rollback-api.sh` |
| What operational work remains? | `../../operations/ROLLBACK_AND_OBSERVABILITY.md` |

## Related wiki pages

- [[Ktor API]]
- [[Frontend Applications]]
- [[API Contract and Data Flow]]
- [[Build and Delivery]]
- [[Operations and Quality Attributes]]
