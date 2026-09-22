# Phase 02 - Make Deployment Pre-Traffic Safe

## Goal

Verify the exact candidate revision before production traffic moves, promote only that named revision, and preserve deterministic recovery and evidence for every failure stage.

## Work

- [x] Capture the pre-deploy serving revision, immutable image digest, traffic allocation, generated URL, and canonical-host verification result before creating a candidate.
- [x] Change the deploy step to create a zero-traffic candidate with a unique, DNS-safe traffic tag derived from the build ID. Do not use `--to-latest` as the promotion target because “latest” can change under concurrent or break-glass activity.
- [x] Resolve the candidate revision by its build label and verify its image digest, readiness condition, runtime identity, probes, resources, scaling, and zero production traffic before calling its tagged URL.
- [x] Run the strengthened Phase 01 verification against the tagged candidate URL. A failure must leave the prior production traffic allocation unchanged.
- [x] Promote the exact candidate revision to 100 percent only after candidate verification passes. Serialize all deployment and rollback entry points using one enforceable lock or policy, not merely documentation.
- [x] Verify both the generated service URL and canonical hostname after promotion. If either post-promotion check fails, restore the captured prior revision and verify recovery; retain evidence of the candidate failure, promotion attempt, rollback, and final traffic state.
- [x] Remove the temporary traffic tag after successful verification or rollback so stale tags do not accumulate or impede revision cleanup.
- [x] Make `CI_COMMIT_SHA` and repository identity mandatory and format-validated. Never mark a release `known-good` when either value is missing or `unavailable`.
- [x] Upload staged evidence even on failure. Separate candidate evidence, promotion evidence, canonical verification, recovery evidence, and final state. Ensure a failed evidence upload does not erase local diagnostic output from the build log.
- [x] Make the rollback workflow consume the same retained Cloud Storage release schema produced by routine automatic builds, or generate an equivalent signed/provenance-checked artifact that the workflow can retrieve without depending on an unrelated manual deployment run.
- [x] Add build-level tests or a dry-run harness that proves ordering: deploy at zero traffic → candidate verify → named promotion → canonical verify → evidence finalization, with rollback after any post-promotion failure.

Repository implementation completed on 2026-09-21. Local dry-run coverage proves successful ordering, zero-traffic isolation for a contract-invalid candidate, shared lock use, temporary-tag cleanup, failure evidence upload, and restoration of the captured traffic allocation after a post-promotion verification failure. The dedicated lock bucket and controlled production validation remain operator work; Phase 02 is not complete until the controlled validation and negative drill below are evidenced.

## Remaining operator work

### 1. Provision the shared deployment lock

Use an operator identity authorized to create buckets and manage bucket IAM. The lock bucket must be separate from the retained release-evidence bucket because the evidence bucket's 30-day retention policy would prevent routine lock deletion. Create the bucket in the Cloud Run region with uniform bucket-level access and public-access prevention, with no retention policy and no soft-delete retention:

```sh
PROJECT_ID=sedaia-web-platform-api-508804
REGION=us-central1
LOCK_BUCKET=sedaia-api-deployment-lock-${PROJECT_ID}
BUILD_SA=sedaia-api-builder@${PROJECT_ID}.iam.gserviceaccount.com
ROLLBACK_SA=sedaia-api-rollback@${PROJECT_ID}.iam.gserviceaccount.com

gcloud storage buckets create "gs://${LOCK_BUCKET}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access \
  --public-access-prevention \
  --soft-delete-duration=0

gcloud storage buckets add-iam-policy-binding "gs://${LOCK_BUCKET}" \
  --member="serviceAccount:${BUILD_SA}" \
  --role=roles/storage.objectAdmin

gcloud storage buckets add-iam-policy-binding "gs://${LOCK_BUCKET}" \
  --member="serviceAccount:${ROLLBACK_SA}" \
  --role=roles/storage.objectAdmin
```

`roles/storage.objectAdmin` is the temporary predefined role that supplies the required object create, read, and delete operations at bucket scope. Phase 03 must measure those operations and replace it with a narrower custom role if practical; do not grant either identity project-wide Storage Admin for this lock.

- [ ] Confirm the bucket location is `US-CENTRAL1`, uniform bucket-level access is enabled, public-access prevention is enforced, and no retention policy is present: `gcloud storage buckets describe "gs://${LOCK_BUCKET}"`.
- [ ] Confirm the bucket IAM policy names only the intended administrative principals plus the build and rollback service accounts: `gcloud storage buckets get-iam-policy "gs://${LOCK_BUCKET}"`.
- [ ] Confirm `gs://${LOCK_BUCKET}/production-api.lock` does not exist before validation. If it exists, read its owner and verify that the named build or rollback is no longer running before removing it; never delete a live operation's lock.
- [ ] Retain the bucket description and IAM policy output as Phase 02 operator evidence, redacting only unrelated sensitive principal details if required.

### 2. Preflight the reviewed repository state

Run the repository verification from the exact commit proposed for `main`. Do not begin production validation with unrelated working-tree changes, an unreviewed commit, or failed checks.

```sh
scripts/tests/deploy-cloud-run-safe-test.sh
scripts/tests/verify-api-deployment-test.sh
./gradlew :apps:api:check --no-daemon
git diff --check
```

- [ ] Confirm the pull request contains the Phase 02 implementation, has required approval, and passes CI, including the rollout-ordering harness.
- [ ] Confirm the regional `sedaia-api-main` trigger remains the sole routine deployer and targets `cloudbuild.yaml` on protected `main`.
- [ ] Confirm no deployment, rollback, or stale lock is active immediately before merging.
- [ ] Record the reviewed 40-character commit SHA as `GOOD_SHA` and the expected repository identity as `Sedaia-Designs/sedaia-web-platform`.

### 3. Run the positive controlled validation

Merge one harmless reviewed API change through protected `main`; a comment-only or response-content correction that preserves the documented contract is sufficient. Do not submit a second manual build. Observe the automatic regional trigger and record the single build UUID as `GOOD_BUILD_ID`.

```sh
PROJECT_ID=sedaia-web-platform-api-508804
REGION=us-central1
SERVICE=sedaia-api
EVIDENCE_BUCKET=sedaia-api-release-evidence-${PROJECT_ID}

gcloud builds list \
  --project="${PROJECT_ID}" \
  --region="${REGION}" \
  --filter="substitutions.COMMIT_SHA=${GOOD_SHA}" \
  --format='table(id,status,createTime,buildTriggerId,substitutions.REPO_FULL_NAME)'

gcloud storage cp \
  "gs://${EVIDENCE_BUCKET}/${GOOD_BUILD_ID}/release.json" \
  "/tmp/${GOOD_BUILD_ID}-release.json"

jq '{schema_version,status,source,cloud_build,cloud_run,image,pre_deploy_traffic,final_traffic,verification,outcome}' \
  "/tmp/${GOOD_BUILD_ID}-release.json"

gcloud run services describe "${SERVICE}" \
  --project="${PROJECT_ID}" \
  --region="${REGION}" \
  --format=json
```

- [ ] Prove the commit produced exactly one regional trigger build and that its `buildTriggerId`, repository, branch, and full commit SHA match the reviewed `main` change.
- [ ] From build logs and retained JSON, prove the prior state was captured before `run deploy`, the candidate was created with `--no-traffic`, and the candidate revision had zero production traffic when its tagged URL was verified.
- [ ] Prove the candidate revision name and `sha256` digest match its build label, runtime identity, probes, resource limits, scaling limits, and retained candidate evidence.
- [ ] Prove candidate verification completed before the exact named revision was promoted; reject evidence that uses `LATEST` or `--to-latest`.
- [ ] Prove the generated service URL and `https://api.sedaia-designs.org` both passed the Phase 01 contract after promotion.
- [ ] Prove schema-v2 `release.json` has status `known-good`, mandatory repository and 40-character commit provenance, the candidate at 100 percent final traffic, `outcome.promoted == true`, and `outcome.temporary_tag_removed == true`.
- [ ] Prove the temporary `build-...` traffic tag and `gs://${LOCK_BUCKET}/production-api.lock` are absent after completion.
- [ ] Retain the Cloud Build URL, build UUID, commit SHA, revision name, image digest, release-evidence prefix, final service JSON, and verification timestamp in this note before starting the negative drill.

### 4. Run the zero-traffic negative drill

Schedule a low-risk operator window and prepare a short-lived reviewed drill commit. Change the `/v1` metadata response to an unmistakable invalid value such as `version = "phase-02-negative-drill"` and update only the corresponding Kotlin route assertion so `:apps:api:check` passes; intentionally leave the OpenAPI contract and `scripts/verify-api-deployment.sh` unchanged. This makes the container technically ready while ensuring the external candidate contract verification fails. The pull request must state that the commit is a temporary Phase 02 negative drill, must not contain unrelated changes, and must have an approved immediate revert ready before merge.

- [ ] Merge the drill commit through protected `main`, record its 40-character SHA as `BAD_SHA`, and confirm exactly one automatic regional build starts for it.
- [ ] Observe the build through candidate creation. Confirm the revision reaches Cloud Run readiness and its tagged URL is tested, but do not manually move traffic or rerun the build.
- [ ] Confirm the build fails at `verify-candidate`, no command promotes the candidate, and the previously known-good revision remains at the same production allocation throughout the drill.
- [ ] Confirm the canonical production API continues to satisfy `scripts/verify-api-deployment.sh https://api.sedaia-designs.org` while the failed candidate exists at zero percent.
- [ ] Retrieve `gs://${EVIDENCE_BUCKET}/${BAD_BUILD_ID}/release.json` and prove `status == "failed"`, `outcome.promoted == false`, the candidate revision and digest are recorded, final serving traffic matches the positive validation revision, and the temporary traffic tag was removed.
- [ ] Confirm the shared lock was released and no duplicate build ran for `BAD_SHA`.
- [ ] Immediately merge the prepared revert through protected `main`; verify its automatic build completes as a new known-good release before ending the operator window.
- [ ] Retain the failed build URL, `BAD_BUILD_ID`, `BAD_SHA`, candidate revision, digest, evidence prefix, unchanged production traffic, canonical verification, revert commit, and successful revert build as the negative-drill record.

### 5. Account for post-promotion recovery

The local dry-run harness already proves that a post-promotion verification failure invokes restoration of the captured traffic allocation, verifies recovery, removes the candidate tag, and uploads failure evidence. Do not manufacture a production hostname or application outage merely to repeat that path. A live post-promotion drill is optional and may run only after an operator approves a reversible method that cannot create customer-visible failure; otherwise retain the local harness output as the Phase 02 recovery-path evidence and defer a live exercise to an isolated Cloud Run drill service.

- [ ] Attach the successful `scripts/tests/deploy-cloud-run-safe-test.sh` output to the Phase 02 evidence record.
- [ ] If an isolated live recovery drill is approved, record the separate service, fault-injection method, captured allocation, promotion, automatic restoration, generated and canonical verification, tag cleanup, lock cleanup, and evidence prefix; never aim fault injection at the production canonical hostname.

### 6. Close the operator gate

- [ ] Add a dated validation record to this note containing the positive build, negative build, revert build, revisions, digests, evidence locations, final traffic, and operator identity.
- [ ] Verify production ends on the intended reviewed revision at 100 percent traffic, both generated and canonical verification pass, no temporary tag remains, and no lock object remains.
- [ ] Mark Phase 02 complete only when every operator checkbox above is satisfied or the optional live recovery drill is explicitly documented as deferred in favor of the passing isolated harness evidence.

## Controlled validation

Use a harmless reviewed API change merged through protected `main`. Confirm exactly one build for the commit, zero candidate traffic during preflight, successful tagged-URL verification, promotion of the named revision, 100 percent final traffic, canonical verification, retained evidence, and removal of the temporary tag. Then run a controlled negative drill using a candidate that fails contract verification but becomes technically ready; prove it receives zero production traffic. Test post-promotion recovery only with a safe reversible method approved by the operator and never manufacture a customer-visible outage.

## Exit criterion

A good candidate is verified before receiving traffic and promoted by immutable revision name; a bad candidate remains at zero percent; a failed post-promotion check restores the captured prior revision; every outcome retains source, digest, revision, traffic, verification, and recovery evidence.
