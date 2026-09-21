# Phase 09 - Business Frontend Completion and Gate

## Goal

Replace the Solid starter with the approved business experience and prove catalog/download behavior, accessibility, responsiveness, SEO, monitoring, deployment, and rollback readiness.

## Scope

Routes/content/components, catalog/releases/downloads, API/CDN integration, loading/error/empty states, navigation/404, metadata/SEO, legal/privacy content, accessibility, responsive design, Vercel environments, promotion, and rollback.

## Prerequisites

Phase 01 business requirements, Phase 07 staging API, Phase 06 delivery flows, approved content/design assets, and named site owner.

## Decisions before execution

Approve launch routes and copy, product information architecture, public/restricted download UX, authentication entry if required, SEO/social metadata, analytics/privacy, browser support, and manual promotion approvers.

## Repository areas and hosted systems

`apps/business`, `packages/api-client` if generated, Vercel Business project/environments/domain, API, asset domain, analytics/error monitoring.

## Ordered steps

- [ ] Remove demo counter/users content and implement only approved launch routes, components, navigation, footer, legal/contact information, metadata, and structured data.
- [ ] Add typed API consumption with explicit loading, error, empty, stale, retry, and unavailable-download states; validate untrusted response content and URLs.
- [ ] Implement release/artifact selection, compatibility/license/checksum display, safe public downloads, and restricted grant/expiry/refresh UX without exposing internal object keys unnecessarily.
- [ ] Ensure anchors are used for navigation/downloads, buttons for actions, download filenames are clear, and status is not conveyed by color alone.
- [ ] Configure development, protected preview/staging, and production origins with no secrets in browser variables and no permissive production CORS for previews.
- [ ] Test routing/deep links/404 behavior under the Vercel rewrite, canonical URLs, sitemap/robots policy if required, metadata/social cards, and HTTP behavior limitations of the SPA; reconsider SSR only through an approved architecture decision.
- [ ] Perform automated and manual WCAG 2.2 AA-oriented keyboard, focus, heading/landmark, form/error, async announcement, contrast, target size, zoom/reflow, reduced motion, screen-reader, and responsive tests.
- [ ] Build a staged production deployment without domain assignment; verify API/CDN/download flows, security headers if adopted, performance budgets, monitoring, and legal/product approval.
- [ ] Exercise known-good Vercel rollback/domain reassignment and retain evidence. Keep Git deployment disabled through final acceptance.

## Security and operational considerations

Do not infer entitlements in the browser; Ktor decides restricted access. Avoid token leakage through URLs, logs, referrers, and analytics. Use safe external-link handling and validate displayed checksums against API metadata.

## Test strategy

Unit/contract/E2E tests, production build, deep-link/404 tests, public/restricted/expired download tests, network faults, accessibility and responsive review, SEO checks, performance budgets, staged DNS/TLS, monitoring, and rollback drill.

## Acceptance criteria

No starter/demo content remains; approved routes and release flows work across responsive and assistive scenarios; privacy/legal/SEO requirements pass; exact staged deployment and rollback are approved; automatic Git deployment remains disabled.

## Evidence to retain

Content/product approvals, commit/deployment IDs, environment inventory, build/test/E2E/a11y/SEO/performance reports, download traces/checksums, domain/TLS and monitoring results, and rollback evidence.

## Rollback or recovery

Reassign the production domain to the known-good Vercel deployment. Disable affected download UI or API feature flags/config as approved; never grant access client-side to work around an outage.

## Dependencies

Depends on Phases 06–07 and may run parallel with Phase 08. Blocks Business promotion in Phase 13.

## Exit criterion

The exact staged Business deployment is product-complete for launch and passes API, CDN, security, accessibility, responsive, SEO, monitoring, and rollback gates.
