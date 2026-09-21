# Phase 06 - Final Verification

## Goal

Prove the remediated production path from reviewed source through safe deployment, monitoring, rollback, and legacy retirement.

## Repository verification

- [ ] Run `./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon` from the reviewed `main` commit.
- [ ] Run the verification-script negative and positive test suite and confirm contract failures cannot be recorded as known-good.
- [ ] Run `git diff --check` and review `gcloud meta list-files-for-upload` for secrets, credentials, caches, dependencies, local notes, frontend packages, and build output.
- [ ] Confirm `Api.kt`, response models, OpenAPI, Kotlin tests, deployment verification, and evidence schema express the same contract.
- [ ] Confirm deploy ordering is zero-traffic candidate, tagged verification, named-revision promotion, canonical verification, evidence finalization, and deterministic recovery on failure.
- [ ] Confirm no mutable builder/base tags or runtime package installations remain unless an explicit approved exception is documented.
- [ ] Confirm README, runbook, workflows, scripts, and all active plan orchestration notes name the same routine deployer, rollback evidence source, monitoring owner, and production platform.

## Hosted verification

- [ ] Confirm exactly one routine trigger targets only `main`, uses the reviewed `cloudbuild.yaml`, and runs as the reduced-permission build identity.
- [ ] Confirm a reviewed commit produced exactly one build, immutable image digest, zero-traffic candidate, successful tagged verification, named promotion, 100 percent final traffic, canonical verification, and retained evidence.
- [ ] Confirm the current Cloud Run revision, digest, runtime identity, ingress, public invocation, port, probes, scaling, resources, concurrency, timeout, labels, and traffic match the reviewed configuration.
- [ ] Confirm a deliberately invalid but technically ready candidate received zero production traffic and retained failure evidence.
- [ ] Confirm generated and canonical URLs pass readiness, exact portfolio contract, positive and negative CORS, DNS, and TLS verification.
- [ ] Confirm all four alert policies are enabled, use the intended channel, show safe condition-validation evidence, and have acknowledged delivery evidence.
- [ ] Confirm release evidence and logs meet retention requirements, cleanup preserves the current and previous rollback images, and SBOM/scanning or accepted-risk evidence exists.
- [ ] Perform a controlled rollback to a previous known-good immutable revision without rebuilding, verify both endpoints and monitoring, restore the intended revision, and retain the complete drill evidence.
- [ ] Confirm App Engine version `20260918t095626` is stopped, no domain or automation targets App Engine, and the final legacy evidence remains retained.

## Closeout

- [ ] Update [[../GCloudCloudRunSetup/Phase 08 - Final Verification|the original Phase 08]] with the remediation result and evidence links.
- [ ] Mark superseded overlapping plan items accurately without deleting historical evidence.
- [ ] Record the production owner, verification date, reviewed commit, build ID, revision, digest, policy IDs, rollback drill result, App Engine status, residual risks, and next scheduled access/alert review.

## Exit criterion

Every preceding phase and every applicable checkbox above passes from reviewed `main`; a candidate cannot reach production without contract verification; monitoring and rollback are proven; IAM and build inputs are constrained; App Engine is stopped; and no active documentation or automation presents a competing production path.
