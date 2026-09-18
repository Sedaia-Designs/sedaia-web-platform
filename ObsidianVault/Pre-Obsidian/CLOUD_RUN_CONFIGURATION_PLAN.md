# Cloud Run Configuration Plan

> [!NOTE]
> Archived pre-Obsidian plan. Its repository changes are complete. Remaining
> hosted validation is tracked in `../Plans/GitHubActionsMigration/` and
> `../Plans/ProductionReadiness/`.

## Goal

Make the API deployment reproducible by explicitly setting every production
Cloud Run decision instead of inheriting service or platform defaults.

## Planned changes

Implementation status: the GitHub Actions validation, deployment, and rollback
workflows are checked in alongside the unchanged GitLab pipeline. GitHub
production deployment is not ready for cutover until its protected environment,
OIDC provider, deployer identity, and hosted deployment/rollback runs are
validated.

1. Preserve these explicit settings when moving the `deploy-api` workflow from
   `../.gitlab-ci.yml` to GitHub Actions:

   ```sh
   gcloud run deploy "$CLOUD_RUN_SERVICE" \
     --image="$IMAGE_URI" \
     --project="$GCP_PROJECT_ID" \
     --region="$GCP_REGION" \
     --port=8080 \
     --service-account="$CLOUD_RUN_SERVICE_ACCOUNT" \
     --ingress=all \
     --allow-unauthenticated \
     --min-instances=0 \
     --max-instances=3 \
     --memory=512Mi \
     --cpu=1 \
     --concurrency=40 \
     --timeout=30s \
     --quiet
   ```

2. Preserve the existing production identities and region:
   - region: `us-central1`;
   - runtime service account:
     `sedaia-api-runtime@sedaia-web-platform-api-508804.iam.gserviceaccount.com`;
   - deployment service account: a dedicated GitHub Actions deployer identity,
     distinct from the runtime service account.
3. Document these values as checked-in production decisions, including
   scale-to-zero behavior and the three-instance ceiling.
4. Update `PLAN.md` to replace its unspecified maximum-instance limit and
   record the selected port, ingress, memory, CPU, concurrency, and timeout.

## Validation

1. Validate the GitHub Actions workflow YAML, expressions, and shell quoting.
2. Run the applicable formatting checks.
3. Confirm every required Cloud Run flag occurs exactly once in the deployment
   command.
4. Confirm GitHub OIDC is restricted to
   `Sedaia-Designs/sedaia-web-platform` and the protected `production`
   environment, with no stored Google Cloud service-account key.
5. Review the final diff for unrelated changes or credentials.

## Cutover gates

Keep GitLab CI/CD enabled until all of these gates pass:

1. GitHub CI succeeds for a pull request and for the resulting `main` commit.
2. The `production` environment enforces an authorized reviewer when supported
   by the repository visibility and GitHub plan. For a private GitHub Team
   repository, the documented procedural approval fallback is accepted or the
   organization upgrades before cutover.
3. Google Cloud accepts GitHub OIDC only for
   `Sedaia-Designs/sedaia-web-platform` and the intended production context.
4. Deploy API builds, validates, pushes, deploys, verifies, and retains its
   release manifest for 30 days.
5. Roll back API retrieves that manifest by successful deployment run ID,
   rejects invalid provenance, restores the immutable digest, and emits rollback
   evidence.
6. A controlled rollback drill restores the previous known-good revision and
   then the intended current revision.

The complete settings, evidence, negative-test, stability, and cutover sequence
is defined in `GITHUB_UI_VALIDATION_PLAN.md`.

## Scope

This plan records deployment policy and the repository-host migration. Its
implementation will replace the GitLab CI workflow and GitLab-specific
provenance fields without changing application runtime behavior.
