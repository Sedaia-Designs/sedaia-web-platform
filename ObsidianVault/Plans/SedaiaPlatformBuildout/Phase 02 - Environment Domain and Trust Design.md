# Phase 02 - Environment Domain and Trust Design

## Goal

Design reproducible development, staging, and production boundaries, domain/DNS/TLS routing, identities, ownership, and cross-provider trust before resources are changed.

## Scope

Projects/accounts/zones, environment naming, network diagrams, DNS records and TTLs, TLS issuance/renewal, service identities, secret stores, ingress/egress, CORS, and deployment authorities.

## Prerequisites

Phase 01 decisions, current provider-account inventory, and named owners with break-glass contacts.

## Decisions before execution

Choose project/account separation, private networking method, DNS provider/zone owner, staging hostnames, certificate termination points, Cloudflare Worker route layout, and whether private DNS is needed for the SQL label.

## Repository areas and hosted systems

Root deployment files, both `vercel.json` files, `apps/cdn`, `apps/sql`, `operations/`, Google Cloud projects/VPC/DNS/Secret Manager, Cloudflare account/R2/Workers/zone, Vercel projects, domain registrar and authoritative DNS.

## Ordered steps

- [ ] Produce an environment matrix listing every component, account/project, region, hostname, data class, credentials source, deployer, runtime identity, and promotion path.
- [ ] Define dev/staging/prod isolation for Cloud SQL databases/instances as approved, R2 buckets, Workers, Vercel environments, API services, secrets, and evidence stores.
- [ ] Draw trust and data flows, including browser-to-provider, Cloud Run-to-SQL, Ktor-to-Worker authorization, Worker-to-R2, CI-to-provider, backup, monitoring, and operator paths.
- [ ] Inventory current DNS records, TTLs, registrar locks, DNSSEC state, certificate issuers, domain verification records, and rollback values without changing them.
- [ ] Specify final records and TLS owners for all five names; for SQL specify no public record or private-zone-only record according to the approved decision.
- [ ] Define CORS allowlists per environment and prohibit wildcard relaxation for restricted/credentialed operations.
- [ ] Define dedicated build, runtime, migration, backup, monitoring, rollback, and break-glass identities with minimum roles and keyless federation where supported.
- [ ] Define secret creation, rotation, access review, audit log, revocation, and incident procedures; prohibit secrets in Vite/browser variables.
- [ ] Review the design against provider quotas, plan features, and billing ownership.

## Security and operational considerations

Keep production credentials out of previews and pull requests. Prevent staging data from becoming public. Require MFA and least-privilege groups for human operators. Preserve independent DNS/registrar recovery access. Document certificate renewal monitoring.

## Test strategy

Threat-walk every boundary, validate DNS/TLS design with provider documentation, simulate credential compromise and owner loss, and peer-review IAM matrices before any grants.

## Acceptance criteria

Every component has an environment, identity, network path, DNS/TLS owner, deploy authority, evidence destination, and recovery owner; SQL has no public browser/database path; provider plan limitations are accepted.

## Evidence to retain

Approved diagrams, environment and IAM matrices, redacted DNS inventory, certificate plan, CORS matrix, secrets register, quota/cost assumptions, and reviewer approvals.

## Rollback or recovery

The design is changed through superseding ADRs. During later DNS work, retain original records/TTLs and provider verification so rollback can restore the prior endpoint.

## Dependencies

Depends on Phase 01. Enables Phases 03, 05, 10, and 11 in parallel.

## Exit criterion

An operator can identify where every request, secret, identity, record, certificate, and evidence artifact belongs without relying on implicit provider defaults.
