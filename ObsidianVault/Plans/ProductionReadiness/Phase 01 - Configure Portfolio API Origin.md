# Phase 01 - Configure Portfolio API Origin

**Status: In progress.** A Google-managed API origin now exists; custom-domain,
Portfolio configuration, CORS, and runtime verification remain pending.

## Evidence recorded 2026-09-18

- App Engine Standard service `default`, version `20260918t095626`, deployed
  successfully in project `sedaia-web-platform-api-508804`.
- Generated service URL:
  `https://sedaia-web-platform-api-508804.uc.r.appspot.com`.
- The deployment log does not establish endpoint health, DNS/TLS for
  `api.sedaia-designs.org`, or browser-origin CORS behavior.

1. Confirm DNS and TLS for `https://api.sedaia-designs.org` resolve to the
   intended production service, after deciding whether App Engine or the
   previously planned Cloud Run service is the canonical target.
2. Set Portfolio production `VITE_API_BASE_URL` to that origin in Vercel.
3. Record the Vercel project, environment, configuration date, and owner
   without copying secrets.
4. From the deployed Portfolio origin, verify `/v1/portfolio/` returns HTTP 200,
   JSON, and the exact allowed CORS origin.
5. When runtime API behavior is added, verify graceful fallback during API
   unavailability.

Exit criterion: hosted configuration matches the OpenAPI contract and the
deployed Portfolio origin can reach the API without mixed-content or CORS
errors.
