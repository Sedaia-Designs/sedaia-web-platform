# Phase 10 - CI Environments Secrets and Supply Chain

## Goal

Give every independently deployable component deterministic validation, protected promotion, least-privilege identity, provenance, and environment separation without coupling unrelated releases.

## Scope

API, SQL migrations, CDN/Worker, Portfolio, Business, OpenAPI/client, asset manifests, dependency pinning, SBOM/provenance, scanning, secrets, CI permissions, branch/environment protection, and deployment isolation.

## Prerequisites

Phase 02 ownership/identity design and sufficiently stable build contracts from Phases 04–09. Cloud Run remediation remains unchanged.

## Decisions before execution

Approve workflow/provider ownership, affected-path strategy, promotion approvals, artifact/evidence retention, dependency update policy, builder/base-image pinning, SBOM/signature tooling, secret rotation cadence, and exception process.

## Repository areas and hosted systems

`.github/workflows`, `cloudbuild.yaml`, `Dockerfile`, Gradle catalogs/lock/checksums, pnpm lockfile, all apps/packages, scripts, Cloud Build/Artifact Registry, Vercel, Cloudflare, Secret Manager, GitHub environments/OIDC.

## Ordered steps

- [ ] Define a component matrix of validation, build artifact, deploy authority, credentials, concurrency lock, environment, evidence, rollback, and owner.
- [ ] Add independent locked validation for API, migrations against PostgreSQL, Worker/CDN, both frontends, OpenAPI/client drift, and asset-manifest integrity; prove unrelated changes do not deploy other components.
- [ ] Pin actions/builders/base images/dependencies to the approved reproducibility level; remove runtime package installation from release paths or record a reviewed exception under Cloud Run remediation.
- [ ] Generate and retain SBOM/provenance and vulnerability/license results for deployable code and container artifacts; define severity gates and expiring exceptions.
- [ ] Verify Gradle wrapper/checksums, pnpm frozen lock, Worker lock/tool versions, migration checksums, asset SHA-256/signatures, and container digest promotion.
- [ ] Use keyless OIDC/federation and dedicated environment identities where possible; prohibit long-lived cloud keys in repository/provider variables. Inventory, rotate, and test revocation for remaining secrets.
- [ ] Protect production environments, serialize mutations per component, require exact source/ref, retain success/failure evidence, and ensure validation jobs cannot access production credentials.
- [ ] Keep Portfolio and Business automatic Git deployment disabled until their publication gates and Phase 14 pass; document the later approval required to restore it.
- [ ] Integrate database deployment order and compatibility checks so migration failure stops API/frontend promotion and destructive contract work cannot precede the observation window.
- [ ] Test compromised/missing credential, stale artifact, checksum drift, concurrent deploy, failed scan, failed migration, failed candidate, and rollback evidence paths.

## Security and operational considerations

Minimize token permissions and job scopes. Separate build from deploy. Protect evidence from mutation. Redact secrets/tokens from logs and artifacts. Review third-party actions and dependency provenance. Do not give frontend builds server secrets.

## Test strategy

Fresh-checkout builds, CI dry runs, negative permission tests, path-isolation tests, deterministic rebuild/digest comparison where practical, secret scanning, SBOM/vulnerability gates, concurrency tests, and protected-environment/rollback exercises.

## Acceptance criteria

Every component validates independently from locked inputs, production mutations use named least-privilege authority and serialized approvals, provenance/evidence are retained, and a component failure cannot silently publish or deploy unrelated surfaces.

## Evidence to retain

Workflow/build IDs, commit/digests, permission matrices and negative tests, dependency/SBOM/vulnerability/license reports, secret inventory/rotation/revocation results, concurrency/path tests, environment approvals, and retention settings.

## Rollback or recovery

Disable the affected deploy authority, revoke credentials, restore the known-good immutable artifact/config/deployment, preserve forensic evidence, and resume only after the cause and permission scope are reviewed.

## Dependencies

Depends on Phase 02 and integrates outputs of Phases 04–09. Blocks Phase 13. API workflow changes must satisfy Cloud Run remediation rather than duplicate it.

## Exit criterion

One reviewed commit can produce traceable, independently validated, immutable candidates for every changed component without granting validation jobs production mutation rights.
