# Sedaia Web Platform

This repository contains the independently buildable services and websites for
Sedaia Designs. Gradle owns the Kotlin API; pnpm owns the frontend workspace and
the public API contract tooling.

## Ownership

| Path                  | Responsibility                                                     | Build/deployment owner    |
| --------------------- | ------------------------------------------------------------------ | ------------------------- |
| `apps/api`            | Ktor API for `api.sedaia-designs.org`                              | Gradle / Google Cloud Run |
| `apps/business`       | Business site for `sedaia-designs.org`                             | pnpm / Vercel             |
| `apps/portfolio`      | Portfolio for `sakura-sedaia.com`                                  | pnpm / Vercel             |
| `packages/api-client` | Public OpenAPI contract and, when generated, its TypeScript client | pnpm / CI                 |

Changes should stay within one ownership boundary when possible. Shared Gradle
files affect the API, while the root pnpm manifest, workspace file, and lockfile
affect both frontend applications and contract tooling.

## Required tools

- Java 21 (Gradle itself is supplied by the wrapper)
- Node.js 22.18.x
- pnpm 10.22.x, normally enabled with Corepack

From a fresh checkout:

```sh
corepack enable
pnpm install --frozen-lockfile
./gradlew :apps:api:test
pnpm build
```

## Local development

Run only the application you are working on:

```sh
# API: http://localhost:8080
./gradlew :apps:api:run

# Business site
pnpm dev:business

# Portfolio
pnpm dev:portfolio
```

Useful scoped validation commands:

```sh
./gradlew :apps:api:check
pnpm --filter @sedaia-designs/business-site lint
pnpm --filter @sedaia-designs/business-site test
pnpm --filter @sedaia-designs/business-site build
pnpm --filter @sedaia-designs/portfolio lint
pnpm --filter @sedaia-designs/portfolio build
pnpm contract:lint
```

The root `pnpm build`, `pnpm lint`, `pnpm test`, and `pnpm format:check`
commands run the corresponding script in every workspace package that provides
one.

## Environment variables

The current applications require no secrets or checked-in local environment
file. The API listens on port `8080` from
`apps/api/src/main/resources/application.yaml`; Cloud Run configuration must
override that setting with its injected `PORT` value before production
deployment. Future browser-visible configuration must use Vite's `VITE_`
prefix. Secrets must be stored in protected GitLab/Vercel variables or Google
Secret Manager, never in the repository.

## CI

GitLab CI uses path-filtered jobs so unrelated applications do not build:

- API changes run the Gradle check task.
- Business-site changes run lint, tests, and a production build.
- Portfolio changes run lint and a production build.
- API-contract changes lint the OpenAPI document.
- API and container-build changes on the default branch expose a manual,
  serialized production deployment after validation succeeds. Merge-request
  pipelines remain build-only.

Changes to shared workspace files intentionally trigger every affected pnpm
job. See `.gitlab-ci.yml` for the exact path rules.

## Deployment and rollback

The two frontends are separate Vercel projects with their application directory
as the project root. Their checked-in `vercel.json` files select the custom
static build, run a frozen pnpm install followed by the app's build script, and
publish `dist/client`:

| Vercel project | Root directory   | Production domain    |
| -------------- | ---------------- | -------------------- |
| Business site  | `apps/business`  | `sedaia-designs.org` |
| Portfolio      | `apps/portfolio` | `sakura-sedaia.com`  |

Configure each Vercel project to use Node.js 22.x. The business configuration
also rewrites unmatched client-side routes to `index.html`; existing static
files continue to be served directly. Keep environment variables and domains
scoped to their respective Vercel project.

The API deployment job is a blocking manual action on the default branch. It
serializes production releases, builds and pushes a commit-addressed container
image, then deploys it to Cloud Run using GitLab workload identity federation.
After deployment, CI waits for `/health/ready`, verifies that
`/v1/portfolio/` returns HTTP 200 with JSON, and prints the deployed revision
and image digest. Any failed operational or application smoke test fails the
deployment job. Cloud Run credentials remain scoped to the API deployment job.

For rollback, redeploy the last known-good Vercel deployment for the affected
site or route Cloud Run traffic back to the prior revision. Do not roll back an
unrelated application. During the portfolio migration window, the preserved
source repository and its known-good Vercel configuration remain the final
fallback.

The architecture decisions and migration safeguards are recorded in
[PLAN.md](PLAN.md).
