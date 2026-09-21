# Phase 03 - Reduce Privilege and Build Variability

## Goal

Replace broad unmeasured access and mutable build dependencies with the narrowest practical, reviewable production configuration.

## IAM work

- [ ] Inventory every permission used by a successful trigger build, including source fetch, log writing, image push and read, Cloud Run revision creation and traffic update, runtime-service-account attachment, service inspection, and release-evidence object creation.
- [ ] Use IAM Policy Troubleshooter, build audit logs, and a controlled test identity or temporary bindings to distinguish required permissions from historical grants. Do not remove a role from the production builder until an equivalent controlled build succeeds.
- [ ] Replace project-wide `roles/run.admin` with `roles/run.developer` at the narrowest supported scope unless a recorded required permission proves otherwise.
- [ ] Remove `roles/storage.admin`. Grant only the source-object permissions actually needed for builds and object-creator access on `gs://sedaia-api-release-evidence-sedaia-web-platform-api-508804`; prevent overwrite and deletion of retained evidence.
- [ ] Determine whether `roles/cloudbuild.builds.editor` is required by the build execution identity or only by build submitters/trigger infrastructure. Remove it from the builder if a triggered and controlled manual build both succeed without it.
- [ ] Retain repository-scoped `roles/artifactregistry.writer`, `roles/logging.logWriter`, and `roles/iam.serviceAccountUser` only on the intended runtime identity unless measurement justifies a narrower or different binding.
- [ ] Remove the deleted `gitlab-ci-deployer@...` policy member after confirming it is not referenced by any active workload, audit procedure, or fallback.
- [ ] Record before-and-after IAM policies, test build IDs, denied permissions encountered, final rationale, and a rollback procedure for IAM changes.

## Build determinism and supply-chain work

- [ ] Pin Cloud Build step images and Docker build/runtime base images by reviewed immutable digest, with a documented periodic update procedure.
- [ ] Remove `apt-get update` and runtime package installation from the post-deploy evidence step. Use a small reviewed verifier image or an existing pinned builder that already contains the required tools.
- [ ] Ensure the Gradle wrapper version used for API tests and image assembly is consistent; avoid testing with one Gradle image while building with an unrelated wrapper/toolchain combination unless the difference is intentional and documented.
- [ ] Generate and retain an SBOM and vulnerability-scan result for the released image, or record an explicit risk acceptance and owner if container scanning remains disabled.
- [ ] Confirm secrets are absent from the Cloud Build upload inventory and image layers, and confirm release evidence contains no access tokens, credentials, or sensitive headers.

## Exit criterion

Successful automatic deployment, pre-traffic verification, promotion, evidence upload, and rollback work with the reduced bindings; broad superseded roles are removed; build dependencies are immutable or governed by an explicit reviewed update policy; provenance and scanning evidence are retained.
