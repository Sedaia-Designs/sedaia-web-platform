# Phase 00 - Audit and Authority Reconciliation

## Goal

Establish repository and hosted evidence as the baseline, make this plan the single buildout authority, preserve the Cloud Run remediation authority, and prevent historical instructions from being executed.

## Scope

Audit current source, configuration, plans, architecture notes, operations material, relevant history, hosted evidence already retained in plans, and every meaningful Monorepo Buildout checklist item. Reconcile documentation only; do not change application or hosted systems in this phase.

## Prerequisites

- Planning change approval and access to the repository history.
- Read-only access to hosted evidence when execution begins; absence of access means hosted claims remain unverified.

## Decisions before execution

- Confirm this directory is the master buildout authority and Cloud Run remediation remains the narrower API-runtime authority.
- Confirm archived plans are retained evidence and not executable instructions.

## Repository areas and hosted systems

`README.md`, `ObsidianVault/Plans/`, `ObsidianVault/Architecture/`, `ObsidianVault/Archives/Plans/`, `operations/`, all five `apps/` areas, `packages/`, workflows, root build/deployment files, Git history, and evidence identifiers already recorded for GitHub, Cloud Build, Cloud Run, App Engine, Vercel, DNS, and monitoring.

## Ordered steps

- [ ] Record the reviewed commit, branch, worktree state, and every pre-existing staged, unstaged, and untracked change; do not clean or absorb unrelated work.
- [ ] Re-run the repository inventory and compare code/configuration with Architecture notes; correct stale statements such as App Engine ownership, “no API fetch,” and missing SQL/CDN placeholders without rewriting historical evidence.
- [ ] Verify hosted claims from provider APIs or retained immutable evidence; classify repository-only configuration as “implemented, hosted state unproven.”
- [ ] Add dated evidence links to the item-level disposition below when execution changes a classification.
- [ ] Confirm `ObsidianVault/Plans/README.md` names this plan as active master authority and the old plan as superseded.
- [ ] Confirm the old plan retains its history and links here; do not execute its checkboxes.

## Item-level disposition of Monorepo Buildout

| Old item | Classification | Evidence / successor |
| --- | --- | --- |
| Phase 00: Gradle and pnpm roots | Completed and evidenced | `settings.gradle.kts`, `package.json`, `pnpm-workspace.yaml` |
| Phase 00: independently scoped API, Business, Portfolio | Completed and evidenced | `apps/api`, `apps/business`, `apps/portfolio` |
| Phase 00: Ktor health and portfolio endpoints/tests | Completed and evidenced | `HealthPlugin.kt`, `Api.kt`, `ServerTest.kt`, `scripts/verify-api-deployment.sh` |
| Phase 00: Cloud Run container/deployment configuration | Completed in repository; hosted acceptance incomplete | `Dockerfile`, `cloudbuild.yaml`, Cloud Run remediation |
| Phase 00: isolated Vercel configuration | Completed in repository; hosted state unproven | both `vercel.json` files |
| Phase 00: public OpenAPI contract | Completed and evidenced for current endpoints | `packages/api-client/openapi.yaml`, CI lint |
| Phase 00: docs/blog absent | Correct but deferred because not among required five surfaces | Product requirements may create a future plan |
| Phase 00: generated client/design tokens/shared config absent | Correct; client decision required, other packages deferred | Phase 07; two-consumer rule remains valid |
| Phase 00: CDN absent | Stale wording; placeholder now exists but implementation is still missing | `apps/cdn/placeholder.md`; Phases 05–06 |
| Phase 00: no Portfolio API consumer | Incorrect/stale after commit `e4642a3` | `apps/portfolio/src/App.tsx`; Phase 08 verifies behavior |
| Phase 01.1: define docs/blog scope | Deferred because requirements are absent | Not on first-release critical path |
| Phase 01.2: create docs/blog | Deferred because requirements are absent | Historical instruction must not be executed now |
| Phase 01.3: isolated app validation/config | Still valid for committed apps; partial | API and existing frontend commands exist; CDN/SQL/Worker paths need Phase 10 |
| Phase 01.4: root commands/path-filtered CI | Partially complete | Root scripts and CI exist, but workflows are not path-filtered and future deployables are absent |
| Phase 02.1: decide generated client versus validation | Still valid | Phase 07 blocking decision |
| Phase 02.2: generate/test if consumers require | Deferred pending the Phase 07 decision | Current portfolio uses a handwritten helper |
| Phase 02.3: add shared packages only for two consumers | Still valid and reusable | No demonstrated design-token/shared-config need yet |
| Phase 02.4: independently runnable package/contract checks | Partially complete | `pnpm contract:lint` exists; generated-client drift test absent |
| Phase 03.1: confirm dynamic behavior | Partially complete but product approval missing | Contact content is fetched; fallback/ownership decision remains Phase 08 |
| Phase 03.2: async helper and static resilience | Partially complete | `asyncFetch` exists; loading/error/empty/offline acceptance is unproven |
| Phase 03.3: environment-driven API origin | Partially complete | Verify actual helper/env resolution and Vercel environment before publication |
| Phase 03.4: success/unavailable/malformed/CORS tests | Required but incomplete | API verifier covers contract/CORS; browser states and malformed/offline tests remain Phase 08 |
| Phase 03.5: hosted coordination | Still valid | Replaced by explicit Phase 08 gate and Phase 13 publication |
| Phase 04.1: identify shared asset | Superseded by approved first-release release/media requirements | Product/release assets justify the surface |
| Phase 04.2: select provider from retention/cache/cost needs | Partially decided, awaiting approval | Provisional R2/CDN/Images; Phases 01, 05–06 |
| Phase 04.3: immutable keys and long cache | Still valid and required | Phase 05 defines conventions and integrity |
| Phase 04.4: publication/invalidation/ownership/recovery | Required but missing | Phases 05–06, 11–12 |
| Phase 05.1: clean locked builds | Partially evidenced, must be rerun per release | Existing CI/build scripts; Phase 10 |
| Phase 05.2: independent builds/lint/tests | Partially complete | API and frontends covered; SQL/CDN pipelines absent |
| Phase 05.3: ownership-boundary isolation | Required but not proven for all future components | Phase 10 and Phase 13 |
| Phase 05.4: App Engine versus Cloud Run | Superseded | Cloud Run is authoritative; Cloud Run remediation owns remaining gates |
| Phase 05.5: preview/staging evidence | Partially complete for API only | Retain per-surface evidence in Phase 13 |
| Phase 06.1: recheck historical acceptance | Still valid but broadened | Phase 14 |
| Phase 06.2: document owners | Required but incomplete | Phases 01–02 and operator handoff |
| Phase 06.3: clean build without secrets/local state | Still valid | Phase 10 and Phase 14 |
| Phase 06.4: API health/readiness/contract/CORS | Implemented and repeatedly tested; persistence additions require new checks | Cloud Run remediation and Phase 07 |
| Phase 06.5: hosted evidence for every surface | Required and missing for most surfaces | Phases 13–14 |
| Phase 06.6: defer or separately plan decisions | Still valid | Phase 01 decision register and scope tiers |
| Database, private connectivity, migrations, object integrity, restricted delivery, DR, cost, abuse controls, five-surface acceptance | Required but missing from old plan | Added by Phases 01–14 of this plan |

## Security and operational considerations

Do not infer hosted completion from repository configuration. Do not reveal credentials in evidence. Historical App Engine deployment, GitHub deployment migration, and old production-readiness steps are explicitly non-executable. App Engine fallback retirement remains governed only by Cloud Run remediation Phase 05.

## Test strategy

Check every cited path/commit, compare active-plan links, validate that each old checklist row has exactly one disposition, and have a second reviewer sample hosted classifications against retained evidence.

## Acceptance criteria

- Every old phase and meaningful item appears in the disposition table.
- Active, superseded, archived, and subordinate authorities are unambiguous.
- Current-state claims distinguish implemented, deployed-but-unproven, scaffolding, blocked, and deferred work.
- Stale architecture statements are either corrected in current documentation or explicitly tracked for correction.

## Evidence to retain

Reviewed commit, `git status`, inventory output, relevant diffs/log entries, hosted read-only query outputs, evidence URLs/IDs, reviewer/date, and the final link-check report.

## Rollback or recovery

Documentation-only changes can be reverted by restoring the prior notes from Git. Never delete historical evidence to resolve authority conflicts; restore it under Archives and link it to the current authority.

## Dependencies

This phase starts first. Every later phase depends on its authority map; it depends on Cloud Run remediation only for truthful status, not completion.

## Exit criterion

One reviewed, evidence-backed authority map exists; the old plan is fully dispositioned; no historical instruction can reasonably be mistaken for an active production procedure.
