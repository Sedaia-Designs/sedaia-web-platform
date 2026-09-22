# Phase 06 - CDN Images and Download Delivery

## Goal

Deliver public assets and responsive images efficiently while enforcing restricted-download authorization, safe headers, cache behavior, CORS, expiry, and abuse controls.

## Scope

Custom domain, Worker routes, R2 bindings, public and private flows, signed authorization, image transformations, cache rules, invalidation, range/HEAD, MIME, disposition, checksums, CORS, WAF/rate limits, analytics, and DNS/TLS.

## Prerequisites

Phases 02 and 05 complete, Phase 07 authorization contract designed, and Cloudflare plan/budget approved.

## Decisions before execution

Approve direct public-bucket custom-domain paths versus Worker paths, token format/key rotation, TTL and replay policy, transformation allowlist/variant widths, fallback behavior at quota limits, cache TTLs, CORS origins, and range support expectations.

## Repository areas and hosted systems

`apps/cdn`, API authorization code/contract, frontend asset consumers, Cloudflare R2/Workers/Cache/Images/WAF/Analytics/DNS/TLS.

## Ordered steps

- [ ] Route `assets.sedaia-designs.org` through the Cloudflare production zone and certificate; keep `r2.dev` disabled for production buckets.
- [ ] Serve public immutable keys with `Cache-Control: public, max-age=..., immutable`, stable ETag/checksum headers where supported, accurate MIME, `X-Content-Type-Options: nosniff`, safe `Content-Disposition`, HEAD, and byte ranges for large downloads.
- [ ] Implement restricted delivery through a Worker private R2 binding. Validate Ktor-issued signature, object/key claim, expiry, not-before, environment, method, and optional audience/nonce before reading R2; reject path manipulation and never log tokens.
- [ ] Keep grant TTL short and define refresh/error UX. Ensure private responses use non-public cache policy unless a reviewed cache-key/auth design proves isolation.
- [ ] Restrict CORS to approved origins/methods/headers and expose only needed response headers; verify expired grants have usable application behavior even where provider CORS error bodies are unavailable.
- [ ] Define image source restrictions and finite responsive variants or width policy, `srcset`/sizes behavior, AVIF/WebP negotiation, quality, crop, metadata stripping, animated/large input rules, and original fallback.
- [ ] Configure WAF/rate/size controls, bot/hotlink policy where appropriate, request logging with privacy/redaction, analytics, and cost/operation alerts.
- [ ] Test cache miss/hit, negative caching, new immutable upload, withdrawal, purge, CORS change, Worker rollback, and origin failure. Purge is exceptional and recorded; normal version changes use new keys.
- [ ] Validate DNS/TLS without publishing links from production applications until Phase 13.

## Security and operational considerations

R2 presigned S3 URLs do not support custom domains and are bearer tokens; the Worker design keeps private bucket access server-side. Avoid secrets in query logs/referrers. Bound transformation inputs to prevent cost amplification. Do not cache authorization failures broadly.

## Test strategy

Automate header/body/checksum/range/HEAD/CORS/cache tests; fuzz paths/tokens; test expired/tampered/replayed grants, unauthorized objects, browser download filenames, representative media formats, responsive rendering, transformation quota fallback, WAF/rate behavior, TLS, and Worker rollback.

## Acceptance criteria

Public assets are immutable and cacheable; restricted objects cannot be read without a valid narrow grant; private buckets have no bypass; images deliver approved responsive formats; DNS/TLS, headers, range, CORS, analytics, alerting, and rollback are proven.

## Evidence to retain

Worker version/digest, routes/bindings, redacted policy/config, DNS/TLS output, header/cache/range/CORS matrices, token negative tests, image/browser results, WAF/rate tests, analytics/alert IDs, purge/rollback drill, and cost estimate.

## Rollback or recovery

Roll back to a retained Worker/config version, disable the affected route, revoke signing keys, withdraw metadata, or temporarily serve known-good immutable objects. Restore objects from Phase 05 authority. Retain old DNS values/TTLs for endpoint rollback.

## Dependencies

Depends on Phases 02 and 05 and coordinates with Phase 07. Blocks frontend download acceptance and Phase 13 publication.

## Exit criterion

Representative public, image, and restricted-download requests pass positive and negative tests at the custom domain with monitoring, cost controls, and a rehearsed rollback.
