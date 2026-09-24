# Phase 01 - Define and Enforce the API Contract

## Goal

Make the production smoke test prove the response contract implemented by `../../../apps/api/src/main/kotlin/org/sedaiadesign/api/routes/Api.kt` instead of merely proving that an endpoint returned some JSON object.

## Decisions before editing

- [x] Require non-empty `programming` and `contact` arrays. The route already contains reviewed production content, so no placeholder content was added.
- [x] Define `/v1` as JSON metadata with the exact stable response `{"name":"Sedaia Designs API","version":"v1"}` and document it in OpenAPI.
- [x] Confirm the implemented stable `PortfolioResponse` fields: `programming` and `contact`; programming items require `title`, `description`, `projectPage`, and `sourceCode`, with optional nullable `documentation`; contact items require `type`, `label`, `icon`, `value`, and `href`.

## Work

- [x] Replace partial assertions in `../../../apps/api/src/test/kotlin/org/sedaiadesign/api/ServerTest.kt` with structural JSON assertions for exact route fields, types, intentional values, and non-empty lists.
- [x] Test allowed production CORS origins, a denied unknown origin, response content types, and the selected `/v1` metadata behavior. Missing fields and wrong types are covered at the deployment-contract boundary by the verifier fixtures.
- [x] Keep `../../../packages/api-client/openapi.yaml`, Kotlin response models, `Api.kt`, and tests synchronized, including non-empty strings and minimum list sizes that reflect the chosen production policy.[^platform-api-contract]
- [x] Strengthen `../../../scripts/verify-api-deployment.sh` so readiness requires an empty JSON object with the JSON content type, metadata is exact, portfolio fields and item types are validated, lists are non-empty, and an untrusted origin must receive HTTP 403 without a CORS allow header.
- [x] Record readiness, metadata, portfolio schema policy, allowed-origin behavior, and denied-origin behavior in the machine-readable verification result.
- [x] Add `../../../scripts/tests/verify-api-deployment-test.sh` and a JVM fixture server covering valid payload, malformed JSON, missing fields, wrong types, invalid CORS, timeout, readiness non-200, and portfolio non-200 responses.[^platform-api-tests]

## Verification

```sh
./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon
scripts/verify-api-deployment.sh LOCAL_TEST_BASE_URL
git diff --check
```

Do not point the strengthened script at production until its negative cases have been proven locally and the selected API content policy is documented.

Local verification completed on 2026-09-20: all verifier fixtures passed, `./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon` succeeded, and `git diff --check` succeeded. Production was not contacted.

## Exit criterion

The route implementation, models, OpenAPI document, Kotlin tests, deployment smoke test, and release evidence enforce one explicit contract, including non-empty `programming` and `contact` collections and the documented `/v1` metadata response.

[^platform-api-contract]: [[../SedaiaPlatformBuildout/Phase 07 - Ktor API and Shared Contract#Ordered steps|Overall Platform Buildout Phase 07]] extends this baseline with backward-compatible catalog, persistence, error, readiness, CORS, rate-control, and shared-client contracts; its new schemas must preserve these synchronized contract rules.
[^platform-api-tests]: [[../SedaiaPlatformBuildout/Phase 07 - Ktor API and Shared Contract#Test strategy|Overall Platform Buildout Phase 07 test strategy]] requires implementation/OpenAPI/client agreement plus negative, dependency, zero-traffic, and rollback-compatibility coverage built on this verifier baseline.
