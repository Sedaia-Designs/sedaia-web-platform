# Phase 03 - Integrate Portfolio API

**Status: Pending.** Repository-side API origin, contract, CORS, and smoke-test
support exist, but the Portfolio is intentionally static and has no runtime API
consumer.

1. Confirm the runtime behavior that genuinely needs the API.
2. Implement an asynchronous helper that preserves useful static rendering
   during API outages.
3. Consume `VITE_API_BASE_URL` without embedding deployment-specific origins.
4. Test success, unavailable API, malformed response, and CORS behavior.
5. Coordinate hosted configuration through the production-readiness plan.

Exit criterion: the deployed Portfolio can use the production API without
making initial rendering depend on API availability.
