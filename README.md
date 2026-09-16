# Sedaia Web Platform

The Sedaia Web Platform is the monorepo for Sedaia Designs' public web presence. It brings together the business website, personal portfolio, documentation, blog, public API, shared frontend packages, and deployment configuration while keeping every application independently buildable and deployable.

## History

This project consolidates the original Sedaia Designs Ktor/SolidJS template and Sakura Sedaia portfolio into a single, purpose-built platform repository.

## Structure

```text
.
├── apps/
│   ├── api/                 # Ktor API deployed to Google Cloud Run
│   ├── business-site/       # sedaia-designs.org
│   ├── portfolio/           # sakura-sedaia.com
│   ├── docs/                # docs.sedaia-designs.org
│   └── blog/                # blog.sedaia-designs.org
├── packages/
│   ├── api-client/          # Typed TypeScript API client and contracts
│   ├── design-tokens/       # Shared visual design tokens
│   └── shared-config/       # Shared frontend tooling configuration
├── infrastructure/
│   ├── cloud-run/           # API deployment configuration
│   └── vercel/              # Frontend deployment configuration
├── buildSrc/                # Gradle convention plugins
├── gradle/                  # Gradle Wrapper and version catalog
├── package.json             # Root scripts and workspace metadata
├── pnpm-workspace.yaml      # pnpm workspace definition
├── settings.gradle.kts      # Gradle project configuration
└── PLAN.md                  # Architecture and rebuild plan
```

See [PLAN.md](PLAN.md) for the architecture, technology baseline, deployment model, and rebuild sequence.
