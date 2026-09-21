# Google Cloud Run Remediation

## Objective

Close the gaps found during the 2026-09-20 audit of [[../../Archives/Plans/GCloudCloudRunSetup/Orchestration|Google Cloud Run setup]], prove that a release is safe before it receives production traffic, establish actionable monitoring and least-privilege access, reconcile stale operational documentation, and retire the App Engine fallback only after every prerequisite is evidenced.

## Scope and authority

This plan is the active remedy for incomplete or weak Cloud Run setup items. The original setup plan remains the historical execution record. [[../../Archives/Plans/ProductionReadiness/Orchestration|Production readiness]] and [[../../Archives/Plans/GitHubActionsMigration/Orchestration|GitHub Actions migration]] contain stale App Engine assumptions and must be reconciled in Phase 00; they must not be independently executed as competing deployment plans. This plan does not authorize deleting evidence, force-pushing, weakening branch protection, or retiring App Engine before the Phase 05 gate.

## Audit findings

| Priority | Finding | Evidence and risk | Remedy phase |
| --- | --- | --- | --- |
| Critical | A new revision is routed to production before post-deploy verification. | `cloudbuild.yaml` deploys without `--no-traffic`, then runs `update-traffic --to-latest`, and only afterward creates verification evidence. A broken but technically ready revision can receive all traffic before the application smoke test runs. | [[Phase 02 - Make Deployment Pre-Traffic Safe]] |
| High | Hosted alerting and notification delivery are absent. | The final verification found one uptime check and one logs-based metric but zero alert policies and zero notification channels. Failures can remain unreported. | [[Phase 04 - Complete Monitoring and Operational Proof]] |
| High | Production verification is too permissive for the API contract. | `scripts/verify-api-deployment.sh` accepts any JSON object. The route in `../../../apps/api/src/main/kotlin/routes/Api.kt` currently returns a fixed owner and headline with `projects = emptyList()`, while tests only search for the owner substring. Wrong or incomplete payloads can pass deployment. | [[Phase 01 - Define and Enforce the API Contract]] |
| High | Deployment ownership is internally inconsistent. | The regional `main` trigger is live, but the README still calls it eventual and describes the manual GitHub deployment as the blocking production action. The manual workflow can submit the same `cloudbuild.yaml` for a commit already deployed by the trigger. | [[Phase 00 - Reconcile Authority and Evidence]] and [[Phase 02 - Make Deployment Pre-Traffic Safe]] |
| High | The build identity is broader than the plan's least-privilege claim. | The builder has project-wide `roles/run.admin`, `roles/storage.admin`, and `roles/cloudbuild.builds.editor`. Evidence upload needs narrow bucket access, Artifact Registry is already repository-scoped, and Cloud Run documents `roles/run.developer` for image deployments. Required permissions have not been measured before granting broad roles. | [[Phase 03 - Reduce Privilege and Build Variability]] |
| Medium | Build execution is not reproducible enough for a production path. | Cloud Build uses mutable `:stable` builder images, the Dockerfile uses mutable base tags, and the evidence step runs `apt-get update` and installs tools after production deployment. Registry or package changes can alter or fail a release independently of repository content. | [[Phase 03 - Reduce Privilege and Build Variability]] |
| Medium | Automatic release provenance can degrade silently. | `create-cloud-build-release-evidence.sh` allows `CI_COMMIT_SHA` and `CI_REPOSITORY` to become `unavailable`, yet still labels the release `known-good`. This weakens traceability for manual or misconfigured builds. | [[Phase 02 - Make Deployment Pre-Traffic Safe]] |
| Medium | Failure evidence and recovery behavior are incomplete. | A failure after traffic movement causes the build to fail but does not automatically restore the captured prior revision. Evidence upload is in the same successful path, so early failures may leave no retained failure record. | [[Phase 02 - Make Deployment Pre-Traffic Safe]] |
| Medium | App Engine retirement instructions are imprecise. | The setup plan says to remove App Engine traffic, but the `default` service cannot be deleted and App Engine traffic migration assigns traffic among versions. The actionable retirement operation is to verify no custom-domain dependency, stop the serving version when rollback authority has moved, preserve evidence, and document reactivation limits. | [[Phase 05 - Retire the Legacy App Engine Path]] |
| Medium | Three active plans contradict the deployed architecture. | Production-readiness and GitHub-migration notes still identify App Engine/Gradle as canonical and mark already-proven Cloud Run work pending. This creates unsafe operator ambiguity. | [[Phase 00 - Reconcile Authority and Evidence]] |
| Low | The public versioned root exposes placeholder text. | `Api.kt` returns `Hello Ktor!` at `/v1/`. This is not a release blocker, but it is an undefined production response and is absent from the OpenAPI contract. | [[Phase 01 - Define and Enforce the API Contract]] |

## Recommended order

1. [[Phase 00 - Reconcile Authority and Evidence]]
2. [[Phase 01 - Define and Enforce the API Contract]]
3. [[Phase 02 - Make Deployment Pre-Traffic Safe]]
4. [[Phase 03 - Reduce Privilege and Build Variability]]
5. [[Phase 04 - Complete Monitoring and Operational Proof]]
6. [[Phase 05 - Retire the Legacy App Engine Path]]
7. [[Phase 06 - Final Verification]]

Complete phases in order. Phase 01 and the repository-only portion of Phase 03 may be developed in parallel, but their changes must merge through the protected `main` branch before Phase 02's controlled deployment. Phase 05 is prohibited until Phases 00–04 pass and the Cloud Run observation window is explicitly accepted.

## Definition of done

- A reviewed `main` commit creates exactly one candidate revision at zero production traffic, validates the exact API contract at its tagged URL, promotes that named revision, validates the canonical hostname, and retains success or failure evidence.
- A failed candidate never receives production traffic; a failed post-promotion check restores the captured prior known-good revision through a tested and evidenced procedure.
- The API response implemented in `Api.kt`, its Kotlin tests, OpenAPI schema, smoke test, and generated evidence assert the same fields, types, CORS behavior, and intentional empty/non-empty project policy.
- The build and runtime identities have only measured permissions at the narrowest practical resource scope.
- Four alert policies are enabled, attached to an owned channel, synthetically validated without harming production, and linked to an accurate runbook.
- Documentation names the regional Cloud Build trigger as the routine deployer and either removes the manual deploy workflow or constrains and documents it as break-glass.
- App Engine no longer serves the legacy API, while its final configuration and rollback-era evidence remain retained for the agreed audit period.
- [[Phase 06 - Final Verification]] passes from the reviewed `main` state with no open predecessor checklist items.

## Authoritative references

- [Cloud Run rollouts, rollbacks, traffic migration, and tagged revision testing](https://docs.cloud.google.com/run/docs/rollouts-rollbacks-traffic-migration)
- [Cloud Run deployment permissions](https://docs.cloud.google.com/run/docs/rollouts-rollbacks-traffic-migration#required-roles)
- [User-specified Cloud Build service accounts](https://docs.cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts)
- [Stop an App Engine version](https://docs.cloud.google.com/appengine/docs/standard/how-instances-are-managed#stop_a_version)
