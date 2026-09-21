# Phase 01 - Define and Enforce the API Contract

## Goal

Make the production smoke test prove the response contract implemented by `../../../apps/api/src/main/kotlin/routes/Api.kt` instead of merely proving that an endpoint returned some JSON object.

## Decisions before editing

- [ ] Decide whether an empty `projects` array is valid production content. If valid, document it and test the empty-array case. If not valid, connect the intended data source or provide reviewed production content; do not add invented placeholder projects solely to satisfy a test.
- [ ] Decide the `/v1/` behavior. Replace `Hello Ktor!` with a documented JSON metadata response or intentionally remove the route and test the selected status. Keep the OpenAPI document aligned.
- [ ] Confirm the stable public fields for `PortfolioResponse`: `owner`, `headline`, and `projects`, plus `id`, `title`, and nullable or optional `description` for each project.

## Work

- [ ] Replace substring assertions in `../../../apps/api/src/test/kotlin/ServerTest.kt` with deserialization or structural JSON assertions for exact required fields, field types, intentional values, and the chosen project-list policy.
- [ ] Add tests for missing or wrong fields where contract validation code exists, allowed production origins, a denied unknown origin, content type, and the selected `/v1/` behavior.
- [ ] Keep `../../../packages/api-client/openapi.yaml`, Kotlin response models, `Api.kt`, and tests synchronized. Add schema constraints such as non-empty strings or minimum project count only when they express an actual product requirement.
- [ ] Strengthen `../../../scripts/verify-api-deployment.sh` so readiness requires the expected JSON body and the portfolio check validates required keys, types, non-empty stable strings, every project item, and the chosen empty/non-empty policy. Add a negative CORS check using an untrusted origin.
- [ ] Record the contract checks in the machine-readable verification result so release evidence shows more than HTTP 200 and generic JSON success.
- [ ] Add automated tests for the verification script using fixture responses or a local test server, covering valid payload, malformed JSON, missing fields, wrong types, invalid CORS, timeout, and non-200 responses.

## Verification

```sh
./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon
scripts/verify-api-deployment.sh LOCAL_TEST_BASE_URL
git diff --check
```

Do not point the strengthened script at production until its negative cases have been proven locally and the selected API content policy is documented.

## Exit criterion

The route implementation, models, OpenAPI document, Kotlin tests, deployment smoke test, and release evidence enforce one explicit contract, including the intentional handling of `projects` and `/v1/`.
