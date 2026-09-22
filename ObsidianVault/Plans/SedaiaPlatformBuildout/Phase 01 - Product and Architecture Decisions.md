# Phase 01 - Product and Architecture Decisions

## Goal

Approve the minimum first-release product and architecture contract before provisioning or implementation creates irreversible commitments.

## Scope

Product catalog, release/download behaviors, business routes/content, portfolio dynamic-content policy, data classifications, retention, availability, `sql.sedaia-designs.org`, restricted access, scanning/signing, RPO/RTO, budgets, and explicit deferrals.

## Prerequisites

Phase 00 complete and named product, platform, security, operations, and content owners available.

## Decisions before execution

- Approve or reject the recommended non-public meaning of `sql.sedaia-designs.org`; public PostgreSQL is prohibited.
- Define launch catalog entities and which downloads are public, restricted, deprecated, or unavailable.
- Set numeric RPO, RTO, retention, budget, expected traffic/file sizes, regional/data-residency needs, and incident ownership.
- Decide minimum malware-scanning service/process and which platforms require signing/notarization.
- Decide whether the API client is generated and whether the portfolio may render remote content without a static fallback.

## Repository areas and hosted systems

`ObsidianVault/Architecture/`, `apps/api`, `apps/business`, `apps/portfolio`, `apps/cdn`, `apps/sql`, `packages/api-client`, product/release source repositories, Google Cloud, Cloudflare, Vercel, DNS, and signing/notarization providers.

## Ordered steps

- [ ] Create approved decision records for hostname meaning, networking, HA/tier, RPO/RTO, bucket layout, entitlement model, release metadata, artifact authority, and frontend promotion.
- [ ] Inventory launch products/releases/assets, owners, licenses, compatibility dimensions, expected sizes, MIME types, signing requirements, and source-of-truth locations.
- [ ] Define publication states such as `draft`, `quarantined`, `approved`, `published`, `deprecated`, `withdrawn`, and `deleted`, including who may transition each state.
- [ ] Define deletion and legal/takedown behavior without promising cache-instant removal for immutable public URLs.
- [ ] Define Business launch routes, content, metadata/SEO, legal/privacy/contact requirements, and download calls to action.
- [ ] Define Portfolio loading, error, empty, stale-cache, and API-outage behavior and whether API content may block initial usability.
- [ ] Record optional/future/deferred capabilities and the trigger that would create a separate plan.
- [ ] Obtain explicit owner sign-off; do not treat an unapproved recommendation as a decision.

## Security and operational considerations

Classify data and artifacts before assigning access. Do not design accounts/payments/CMS without requirements. Treat signed URLs as bearer credentials. Define separation of duties for upload, scan, approval, publication, and emergency withdrawal.

## Test strategy

Walk representative public, restricted, deprecated, compromised, failed-scan, restore, and takedown scenarios through every decision. Verify each scenario has one owner, state transition, evidence record, and recovery path.

## Acceptance criteria

All blocking decisions in Orchestration have an owner and approved outcome; the first-release entity/content list is finite; scope tiers are accepted; RPO/RTO and budgets are numeric; no database port is publicly exposed.

## Evidence to retain

Approved ADRs/decision log, product matrix, data classification, RPO/RTO and budget approval, release-policy approval, owner/contact register, and deferred-scope register.

## Rollback or recovery

Before provisioning, reverse a decision by superseding its ADR and updating dependent phases. After provisioning, create a reviewed migration/change plan; do not silently edit the historical decision.

## Dependencies

Depends on Phase 00. It blocks Phases 02–09; independent Cloud Run remediation may continue unchanged.

## Exit criterion

Every choice that materially changes network exposure, schema, artifact policy, cost, user experience, or publication authority is either approved or explicitly blocks its dependent work.
