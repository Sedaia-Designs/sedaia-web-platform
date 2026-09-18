# Sedaia Web Platform

This repository contains the independently buildable services and websites for
Sedaia Designs. Gradle owns the Kotlin API; pnpm owns the frontend workspace and
the public API contract tooling.

## Ownership

| Path                  | Responsibility                                                     | Build/deployment owner    |
| --------------------- | ------------------------------------------------------------------ | ------------------------- |
| `apps/api`            | Ktor API for `api.sedaia-designs.org`                              | Gradle / App Engine Standard |
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
`apps/api/src/main/resources/application.yaml`; App Engine Standard starts the
packaged application through `apps/api/src/main/appengine/app.yaml`. Future
browser-visible configuration must use Vite's `VITE_` prefix. Secrets must be
stored in protected CI/Vercel configuration or Google Secret Manager, never in
the repository.

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

GitHub Actions is being introduced alongside GitLab CI. The initial port lives
in `.github/workflows` and provides:

- pull-request and `main` validation for the API, frontends, and OpenAPI
  contract;
- a manually dispatched production API deployment that accepts only `main`,
  requires explicit confirmation, invokes the established Gradle App Engine
  deployment task, and publishes a 30-day known-good release manifest; and
- a manually dispatched rollback that retrieves a manifest from a successful
  Deploy API workflow run and verifies its provenance before changing traffic.

The GitHub `production` environment must use the strongest approval control
available for the repository visibility and GitHub plan. GitHub documents that
required reviewers for private repositories are not available on GitHub Team;
that case requires the recorded procedural fallback or a plan upgrade. Define
these environment or repository variables before exercising production:

- `GCP_WORKLOAD_IDENTITY_PROVIDER`: the full Google Workload Identity provider
  resource name configured for GitHub OIDC;
- `GCP_SERVICE_ACCOUNT`: the dedicated GitHub Actions deployment service
  account.

Both production workflows share the `production-api` concurrency group and use
the protected `production` environment. Do not disable GitLab CI/CD until the
GitHub validation workflow passes on pull requests and `main`, OIDC
authentication succeeds, and controlled deployment and rollback runs complete.
The complete manual configuration and evidence checklist is in
[the GitHub Actions migration plan](ObsidianVault/Plans/GitHubActionsMigration/Orchestration.md).

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

The Portfolio production environment must define `VITE_API_BASE_URL` as
`https://api.sedaia-designs.org`. This exposes only the public API origin to a
future asynchronous client helper; the current static portfolio has no runtime
dependency on the API.

The GitHub API deployment is a blocking manual action on `main`. It serializes
production releases, authenticates with Workload Identity Federation, and runs
`./gradlew :apps:api:appengineDeploy --no-configuration-cache`. Gradle owns
assembly, App Engine staging, and deployment. Each workflow run assigns a
deterministic immutable App Engine version, confirms service `default` in
project `sedaia-web-platform-api-508804`, verifies final traffic, then checks
`/health/ready` and `/v1/portfolio/` for HTTP 200, JSON, and the expected CORS
origin.

Successful deployments publish a 30-day machine-readable release manifest
containing the source commit, immutable App Engine version, traffic allocation,
and verification evidence. API rollback is protected, manual, and serialized:
it accepts a retained known-good deployment run, verifies GitHub provenance and
version existence, routes traffic to that existing version without rebuilding,
and reruns production verification. Monitoring and retention setup, alert
response guidance, and the controlled drill procedure are in
[operations/ROLLBACK_AND_OBSERVABILITY.md](operations/ROLLBACK_AND_OBSERVABILITY.md).

No approved `automatic_scaling.max_instances` value is recorded yet. Production
owners must decide the capacity/cost limit before final sign-off; the repository
does not choose an arbitrary value.

For a frontend rollback, redeploy the last known-good Vercel deployment for the
affected site. Do not roll back an unrelated application. During the portfolio
migration window, the preserved source repository and its known-good Vercel
configuration remain the final fallback.

Architecture decisions originated in
[the archived monorepo plan](ObsidianVault/Pre-Obsidian/PLAN.md). Remaining
implementation is tracked in the
[active monorepo buildout plan](ObsidianVault/Plans/MonorepoBuildout/Orchestration.md),
and all active feature and refactor plans are indexed under
[`ObsidianVault`](ObsidianVault/Plans/).
