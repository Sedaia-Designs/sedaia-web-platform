# Phase 08 - Portfolio Integration and Publication Gate

## Goal

Make the Portfolio’s API-backed behavior resilient, accessible, environment-correct, and explicitly approved before any production deployment automation or domain promotion.

## Scope

API adapter/client, origin configuration, loading/error/empty/stale/offline states, static fallback, CORS, content rendering, security, performance, responsive behavior, WCAG 2.2 AA acceptance, Vercel environments, promotion and rollback.

## Prerequisites

Approved product behavior, Phase 07 staging contract, representative CDN media, and Vercel project ownership. Automatic Git deployment remains disabled.

## Decisions before execution

Approve which content is dynamic, fallback/caching policy, failure messaging/retry, markdown/sanitization policy, production and preview API origins, analytics/error monitoring, browser support, and manual promotion approvers.

## Repository areas and hosted systems

`apps/portfolio`, `packages/api-client` if generated, Vercel Portfolio project/environments/domains, API/CORS, `assets.sedaia-designs.org`, uptime/browser monitoring.

## Ordered steps

- [ ] Audit the current promise-based `createMemo` consumption in `App.tsx` and `asyncFetch` behavior against SolidJS 2 semantics; define explicit resource/loading/error/empty states and cancellation/timeouts.
- [ ] Preserve useful initial/static content during API outage according to the approved policy; avoid a blank or permanently pending contact/content area.
- [ ] Validate all remote content before rendering and sanitize any rich text; do not trust API URLs, labels, or markup merely because they originate internally.
- [ ] Configure development, protected preview/staging, and production `VITE_API_BASE_URL` values; confirm no secret enters `VITE_` variables and no preview needs broad production CORS.
- [ ] Add contract tests for success, empty, partial/unknown fields as policy allows, malformed data, timeout, HTTP failure, retry, stale/fallback content, and allowed/denied CORS.
- [ ] Integrate responsive CDN images/assets with dimensions, lazy/eager priority, useful alt text, and graceful transformation/origin failure.
- [ ] Perform automated accessibility checks plus manual keyboard, focus, landmarks/headings, modal/inert behavior, zoom/reflow, contrast, target size, reduced motion, async announcements, screen-reader sampling, and responsive viewport testing.
- [ ] Build a staged production Vercel deployment with production environment values but no domain assignment; verify CSP/security headers if adopted, assets, API, performance budgets, metadata, links, and error monitoring.
- [ ] Exercise instant rollback/domain reassignment to the known-good deployment and retain evidence.
- [ ] Obtain explicit product, accessibility, API-contract, and operations approval. Keep `git.deploymentEnabled: false` until Phase 14 passes and a later decision explicitly restores automation.

## Security and operational considerations

Treat remote content as untrusted. Do not expose private download grants in analytics/referrers. Limit retries to prevent API amplification. Make monitoring distinguish frontend outage, API outage, and expected empty content.

## Test strategy

Unit/contract tests, production build, browser E2E against staging, network fault injection, CORS, keyboard/screen-reader/manual responsive review, performance measurements, external link/download validation, staged-domain/TLS check, and rollback drill.

## Acceptance criteria

Portfolio remains useful during API failure, communicates states accessibly, consumes only the approved origin/contract, passes responsive and WCAG-oriented acceptance, and has approved staged promotion and rollback evidence. Automatic deployment is still disabled.

## Evidence to retain

Commit/deployment IDs, environment-variable inventory without values, build/test/a11y/performance reports, screenshots where useful, CORS/API traces, approval record, domain/TLS verification, monitoring check, and rollback result.

## Rollback or recovery

Reassign the domain to the retained known-good Vercel deployment. If API behavior is unsafe, disable dynamic use or serve the approved static fallback; do not weaken CORS or publish an unreviewed origin.

## Dependencies

Depends on Phases 06–07. Can proceed in parallel with Phase 09. Blocks Portfolio promotion in Phase 13.

## Exit criterion

The exact staged production build passes the approved API, resilience, accessibility, responsive, security, monitoring, and rollback gates with automatic Git deployment still off.
