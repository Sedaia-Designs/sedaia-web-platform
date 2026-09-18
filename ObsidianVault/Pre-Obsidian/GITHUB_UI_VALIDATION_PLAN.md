# GitHub UI Configuration and Validation Plan

> [!NOTE]
> Archived pre-Obsidian plan and historical evidence source. Continue work in
> `../Plans/GitHubActionsMigration/Orchestration.md`.

## Goal

Complete and validate the GitHub-side repository configuration required by the
workflows in `../.github/workflows` without weakening or removing the existing
GitLab CI/CD path. GitHub becomes the deployment source only after every
control below has produced recorded evidence and the stability gates have
passed.

This plan covers settings and validation performed in the GitHub web UI. It
does not authorize a production deployment, rollback, GitLab shutdown, or
deletion of GitLab configuration.

## Current implementation boundary

The repository already contains these GitHub Actions candidates:

- `CI` validates the API, both frontends, and the OpenAPI contract on pull
  requests and pushes to `main`;
- `Deploy API` is manually dispatched, accepts only `main`, requires the
  `deploy-production` confirmation, uses the `production` environment and
  `production-api` concurrency group, authenticates to Google Cloud with OIDC,
  validates the image, deploys it, verifies production, and retains a release
  manifest for 30 days; and
- `Roll back API` is manually dispatched, accepts only `main`, requires the
  `rollback-production` confirmation, uses the same environment and concurrency
  group, retrieves a known-good deployment artifact, verifies its provenance,
  and emits rollback evidence.

The GitLab pipeline remains the operational fallback throughout this plan.

## Roles and required access

Assign named people before changing settings. One person may hold multiple
roles where the GitHub plan does not support enforced separation, but that
limitation must be recorded.

| Role                       | Minimum access             | Responsibility                                                               |
|----------------------------|----------------------------|------------------------------------------------------------------------------|
| GitHub organization owner  | Organization owner         | Billing/plan, Actions policy, repository rulesets, emergency recovery        |
| Repository administrator   | Repository admin           | Repository settings, environments, variables, branch protection              |
| Deployment initiator       | Repository write           | Starts controlled deployment and rollback workflow runs                      |
| Deployment reviewer        | Repository read or greater | Approves or rejects protected-environment jobs when the feature is available |
| Google Cloud administrator | WIF and IAM administration | Creates and restricts the GitHub OIDC provider and deployer identity         |
| Evidence recorder          | Repository read            | Captures run URLs, settings screenshots, artifact contents, and results      |

Do not use a shared human account. Confirm that at least two organization
owners have current access and two-factor authentication before enabling rules
that could lock out the repository.

## Phase 0: Resolve the GitHub plan capability gate

Before configuring the `production` environment, record:

- repository visibility: public, private, or internal;
- organization plan shown under organization billing;
- whether **Required reviewers** and **Prevent self-review** appear for a
  private `production` environment; and
- whether repository or organization rulesets are available at the intended
  enforcement level.

GitHub currently documents that required environment reviewers on Free, Pro,
and Team are available only for public repositories. Therefore:

### [*] Path A: public repository or a plan supporting private required reviewers

Use a required reviewer, enable **Prevent self-review**, and prevent
administrator bypass if the UI and recovery model permit it.

### [ ] Path B: private repository on GitHub Team

Treat the environment as a deployment record and variable boundary, not as an
enforced two-person approval boundary. Keep all existing workflow safeguards:

- manual `workflow_dispatch` only;
- exact typed confirmation;
- `main`-only preflight;
- repository rules requiring reviewed changes and successful CI before `main`;
- OIDC restricted to the repository and `production` environment subject; and
- procedural approval recorded in the change or incident record before the
  initiator runs the workflow.

If enforced two-person production approval is a non-negotiable requirement,
stop here and choose GitHub Enterprise or an independently reviewed deployment
approval system. Do not describe the Team fallback as equivalent enforcement.

Record the selected path and approver:

| Decision                            | Value                                                                                |
|-------------------------------------|--------------------------------------------------------------------------------------|
| Repository visibility               | Public                                                                               |
| GitHub plan                         | Team                                                                                 |
| Required reviewers available        | Yes, Confirmed in the production environment UI                                      |
| Selected protection path            | Path A                                                                               |
| Risk acceptance or upgrade decision | No risk accepted; add a second eligible reviewer before enabling Prevent self-review |
| Decision owner and date             | Sakura — 2026-09-16                                                                  |

## Phase 1: Verify repository import and ownership

In the repository **Settings > General** and the repository home page:

1. Confirm the repository is exactly
   `Sedaia-Designs/sedaia-web-platform`.
2. Confirm `main` is the default branch.
3. Confirm the expected commit, branches, and tags imported from GitLab.
4. Compare the GitHub `main` commit SHA with the intended GitLab source SHA. (Latest Commits SHA Match)
   - `Evidence`
       1. GitHub latest commit SHA (Imported): 6dd4bcee88b98c2f7f6a3afae7bbc6c6e6ad0901
       2. GitLab latest commit SHA (Source): 6dd4bcee88b98c2f7f6a3afae7bbc6c6e6ad0901
5. Confirm the Sedaia Designs team and administrators have the intended access.
   1. `Evidence`: Postpone this step, as there is only one organization member; with no plans to add more. This step will be re-evaluated when more members are added.
6. Review deploy keys, webhooks, GitHub Apps, and collaborators introduced by
   the import. Remove nothing during validation; record unexpected access for a
   separate reviewed cleanup.
   1. `Evidence`: No Apps, deploy keys, or collaborators imported
7. Confirm issues, releases, protected branches, and CI variables that did not
   transfer automatically are explicitly tracked as migration work.
   1. There were no issues, releases, protected branches or CI Variables made in the GitLab repository before this migration

Evidence:

- GitHub repository URL and default branch screenshot; 
- matching source and imported commit SHAs;
    1. GitHub latest commit SHA (Imported): 6dd4bcee88b98c2f7f6a3afae7bbc6c6e6ad0901
    2. GitLab latest commit SHA (Source): 6dd4bcee88b98c2f7f6a3afae7bbc6c6e6ad0901
- exported or captured access list; and
- list of import differences with an owner for every unresolved item.

Exit criterion: the imported repository is complete enough to validate Actions
without new commits landing only in GitLab.

## Phase 2: Configure repository Actions policy

Open **Settings > Actions > General**.

### Actions permissions

Prefer **Allow OWNER, and select non-OWNER, actions and reusable workflows**.
Allow only the publishers currently referenced by the workflows:

```text
actions/*
gradle/actions/*
google-github-actions/*
```

If the organization requires actions pinned to full commit SHAs, first update
every `uses:` entry to an approved immutable SHA. Do not enable that policy
while workflows still use major-version tags because all jobs would fail.

### Workflow permissions

> [!NOTE] Cannot modify settings within this section as they are enforced by the Organization Policy

Set the default `GITHUB_TOKEN` permission to **Read repository contents and
packages permissions**. Leave **Allow GitHub Actions to create and approve pull
requests** disabled. The workflow files grant only the additional job-level
permissions they require:

- CI: `contents: read`;
- deployment: `contents: read` and `id-token: write`; and
- rollback: `contents: read`, `actions: read`, and `id-token: write`.

### Fork pull-request policy

If forks are enabled:

1. do not send write tokens to fork workflows;
2. do not send secrets to fork workflows; and
3. require approval for all external-contributor workflow runs where the UI
   offers that choice.

The CI workflow must remain secretless and read-only on pull requests.

### Retention

Set artifact and log retention to at least 30 days at the repository or
organization level. The deploy and rollback workflows also request 30-day
artifact retention. Record the effective limit because an organization-level
maximum can override the repository.

Evidence:

- screenshots of Actions permissions, workflow permissions, fork policy, and
  retention;
- the effective allowed-action patterns; and
- confirmation that the organization policy does not override these settings.

Exit criterion: all three workflows are enabled with least-privilege defaults
and every referenced action is allowed.

## Phase 3: Create and protect the production environment

Open **Settings > Environments** and create or edit the environment named
exactly `production`.

1. Set deployment branches and tags to **Selected branches and tags**.
2. Add only the `main` branch. Do not allow tags or wildcard branches initially.
3. If Path A from Phase 0 applies:
   - configure the intended user or team under **Required reviewers**;
   - enable **Prevent self-review**;
   - disable administrator bypass if the UI supports it and the documented
     break-glass owners can still recover the repository.
4. If Path B applies, record that reviewer enforcement is unavailable and link
   the approved procedural release policy.
5. Add these environment variables, not secrets:
   - `GCP_WORKLOAD_IDENTITY_PROVIDER`: full provider resource name in the form
     `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL/providers/PROVIDER`;
   - `GCP_SERVICE_ACCOUNT`: dedicated GitHub deployment service-account email.
6. Do not add a Google service-account JSON key. OIDC must remain the only
   Google credential path.
7. Review the deployment history after the first validation run and confirm
   both production workflows resolve to this exact environment.

Evidence:

- environment protection and branch-policy screenshots;
- variable names with values partially redacted where appropriate;
- reviewer or Team-tier fallback decision; and
- first environment deployment record URL.

Exit criterion: only `main` can enter `production`, the expected protection gate
is visible, and the two required OIDC variables resolve in environment jobs.

## Phase 4: Configure and verify Google OIDC trust

This phase is configured in Google Cloud, but its values and result are
validated from the GitHub Actions UI.

1. Create a GitHub-specific Workload Identity pool/provider or a separately
   restricted provider in a shared pool. Do not reuse the GitLab provider.
2. Map the GitHub claims required by the provider and IAM binding.
3. Restrict admission to the exact repository
   `Sedaia-Designs/sedaia-web-platform`.
4. Restrict the production credential path to the expected environment subject:

   ```text
   repo:Sedaia-Designs/sedaia-web-platform:environment:production
   ```

5. Grant `roles/iam.workloadIdentityUser` on the dedicated GitHub deployer
   service account only to the intended GitHub principal set.
6. Give that deployer only the Google Cloud roles required for Artifact Registry
   push, Cloud Run deployment, runtime-service-account use, and release
   inspection. Keep it separate from the Cloud Run runtime account.
7. Verify that no long-lived Google credential is present under repository,
   environment, or organization secrets.
8. Add a temporary read-only authentication-validation workflow before the
   first production deployment. It should enter `production`, authenticate with
   OIDC, print the active account/project, and perform read-only `gcloud`
   describe operations. It must not build, push, deploy, or change IAM.
9. Delete or retain that validation workflow only through a reviewed change
   after the production workflow itself has authenticated successfully.

Negative checks:

- a non-`main` dispatch is rejected by the workflow preflight;
- a job not associated with `production` cannot obtain the production identity;
- a different repository in the organization cannot impersonate the deployer;
  and
- blank or incorrect provider variables cause authentication to fail before any
  Google Cloud mutation.

Evidence:

- provider resource name and redacted attribute condition;
- service-account IAM binding;
- successful read-only validation-run URL; and
- failed negative-test run URLs or Google audit records.

Exit criterion: GitHub can obtain short-lived Google credentials only under the
intended repository/environment context, with no stored service-account key.

## Phase 5: Establish the `main` ruleset

Run `CI` successfully once before selecting required checks so GitHub knows
their exact names. Then open **Settings > Rules > Rulesets** and create an
active branch ruleset targeting the default branch.

Recommended initial rules:

1. block branch deletion;
2. block force pushes;
3. require a pull request before merging;
4. require at least one approval when more than one maintainer is available;
5. dismiss stale approvals after new reviewable commits;
6. require conversation resolution;
7. require status checks to pass;
8. require the branch to be up to date before merging; and
9. require these checks from GitHub Actions:
   - `API`;
   - `Frontends`;
   - `API contract`.

Keep the bypass list empty where practical. If organization owners need
break-glass bypass, configure **For pull requests only** or the narrowest
available bypass mode and document every use. Do not make Vercel checks required
until their names and behavior on unrelated changes are stable.

Validate the ruleset with a disposable pull request:

1. demonstrate that merging is blocked while checks are pending;
2. intentionally create a harmless failing check and demonstrate that merging
   remains blocked;
3. restore the change and demonstrate all three checks passing;
4. confirm direct pushes and force pushes to `main` are rejected for an actor
   without bypass; and
5. merge through the allowed review path.

Evidence:

- ruleset target, enforcement state, rules, and bypass list;
- pull-request URL showing pending, failed, and passing checks; and
- resulting `main` workflow-run URL.

Exit criterion: unreviewed or failing changes cannot reach `main` through the
normal maintainer path.

## Phase 6: Validate CI in the Actions UI

Use the pull request from Phase 5 and its resulting `main` commit.

For the pull-request run, confirm:

- workflow event is `pull_request`;
- `API`, `Frontends`, and `API contract` all appear as separate jobs;
- every job checks out the pull-request revision;
- no job requests `id-token: write` or accesses the `production` environment;
- the Node version is `22.18.0` and Java version is `21`;
- Gradle and pnpm use their locked inputs; and
- logs contain no credentials or unexpected environment values.

For the post-merge run, confirm:

- workflow event is `push` on `main`;
- the tested SHA equals the merged `main` SHA; and
- all three required checks complete successfully.

Re-run one successful job from the UI and confirm the re-run is reproducible.
Download its logs and retain the run URLs in the evidence table.

Exit criterion: CI passes on both events, enforces the ruleset, and exposes no
production credential path.

## Phase 7: Validate manual deployment controls

Do not begin until Phases 0–6 pass and GitLab remains available.

### Preflight negative tests

1. From **Actions > Deploy API > Run workflow**, select a non-`main` ref if the
   UI permits it and confirm preflight rejects it.
2. Run from `main` with an incorrect confirmation value and confirm preflight
   fails before the production job and before OIDC authentication.
3. Confirm no Artifact Registry image, Cloud Run revision, or release artifact
   is produced by either rejected run.

### Protection-gate test

Run from `main` with the exact `deploy-production` confirmation.

- Under Path A, confirm the `Deploy production API` job enters **Waiting**, the
  initiator cannot self-approve, a configured reviewer can reject one test, and
  a later run proceeds only after approval.
- Under Path B, confirm the environment and main-only controls work, then record
  the procedural approval before allowing the run to proceed.

### Controlled production deployment

During an approved low-traffic window:

1. capture the current Cloud Run revision and image digest;
2. start the deployment from the reviewed `main` SHA;
3. verify only one `production-api` job runs at a time;
4. review each step: OIDC, registry authentication, image validation, push,
   deploy, resolution, smoke verification, manifest creation, artifact upload;
5. confirm `/health/ready`, portfolio JSON, and portfolio CORS verification pass;
6. confirm the deployed source label contains the GitHub commit and run ID;
7. download `api-release-manifest` from the run summary;
8. verify its repository, run ID, commit SHA, immutable digest, revision, final
   traffic, and verification results; and
9. confirm the artifact shows a 30-day expiration.

Do not treat a re-run of a partially failed deployment as new evidence without
checking which jobs and steps actually executed in that attempt.

Exit criterion: one approved deployment from `main` produces a verified Cloud
Run revision and a complete retained manifest without GitLab assistance.

## Phase 8: Validate rollback controls and provenance

Rollback validation requires two known-good GitHub deployment manifests.

### Negative tests

1. Use a nonexistent run ID and confirm artifact download fails.
2. Use a successful run ID from a different workflow and confirm provenance
   verification rejects its workflow path or missing artifact.
3. Use an incorrect confirmation and confirm no production job starts.
4. If safe test fixtures are added later, verify that repository, commit, run,
   digest, and verification tampering are rejected before Google Cloud changes.

### Controlled drill

1. Record the current and previous GitHub deployment run IDs, manifests,
   revisions, and digests.
2. Open **Actions > Roll back API > Run workflow** on `main`.
3. Enter the previous successful deployment run ID, the drill reason, and exact
   `rollback-production` confirmation.
4. Complete the environment approval process selected in Phase 0.
5. Confirm provenance verification completes before Google authentication and
   traffic mutation.
6. Confirm rollback routes to the recorded revision when it still exists or
   deploys the recorded digest without rebuilding when it does not.
7. Confirm readiness, portfolio JSON, and CORS checks pass.
8. Download `api-rollback-RUN_ID` and verify the source revision, restored
   revision/digest, reason, timestamps, checks, and final traffic.
9. Restore the intended current release using its known-good deployment run ID
   through the same rollback workflow.
10. Record recovery time and any discrepancy between GitHub deployment history,
    Cloud Run traffic, and the manifests.

Exit criterion: GitHub restores both the previous and intended current immutable
release, and provenance rejection occurs before mutation for invalid inputs.

## Phase 9: Stability observation period

GitHub is not stable after one successful run. Observe it while GitLab remains
intact until all of these minimums are met:

- at least five consecutive successful pull-request CI runs;
- at least five consecutive successful `main` CI runs;
- at least two successful GitHub production deployments on different commits;
- one completed rollback-and-restore drill;
- no unexplained skipped required checks;
- no credential, OIDC, artifact, concurrency, or environment-gate failures;
- artifacts and logs remain downloadable for the documented period;
- all operators can locate runs, approvals, manifests, and rollback evidence;
  and
- at least seven calendar days of stable GitHub operation after the rollback
  drill, or a longer period selected by the deployment owner.

Reset the affected counter after any material workflow, ruleset, environment,
OIDC, or IAM change.

## Phase 10: Cutover decision without GitLab removal

Hold a recorded go/no-go review. A **go** decision permits GitHub to become the
only system initiating new deployments; it does not permit deleting GitLab CI.

For **go**:

1. freeze GitLab production deployment initiation;
2. retain `../.gitlab-ci.yml`, GitLab variables, artifacts needed by the rollback
   window, and GitLab repository access;
3. update operational documentation to identify GitHub as active and GitLab as
   dormant fallback;
4. monitor the first two GitHub-only releases; and
5. create a separate future change, with its own approval and evidence, for any
   GitLab decommissioning.

For **no-go**:

1. keep GitLab active;
2. stop GitHub production dispatches;
3. preserve failed GitHub logs and artifacts;
4. assign every gap an owner and due date; and
5. repeat only the affected phases plus the stability observation period.

## Evidence register

Store links rather than credentials or copied tokens.

| Evidence | Owner | URL or record | Result | Date |
| --- | --- | --- | --- | --- |
| Plan/visibility capability decision | Pending | Pending | Pending | Pending |
| Import/default branch verification | Pending | Pending | Pending | Pending |
| Actions permissions and token policy | Pending | Pending | Pending | Pending |
| Artifact/log retention | Pending | Pending | Pending | Pending |
| Production environment protection | Pending | Pending | Pending | Pending |
| GitHub OIDC provider and IAM review | Pending | Pending | Pending | Pending |
| Read-only OIDC validation run | Pending | Pending | Pending | Pending |
| Active `main` ruleset | Pending | Pending | Pending | Pending |
| Pull-request CI validation | Pending | Pending | Pending | Pending |
| `main` CI validation | Pending | Pending | Pending | Pending |
| Deployment preflight negative tests | Pending | Pending | Pending | Pending |
| First GitHub production deployment | Pending | Pending | Pending | Pending |
| Second GitHub production deployment | Pending | Pending | Pending | Pending |
| Rollback provenance negative tests | Pending | Pending | Pending | Pending |
| Rollback-and-restore drill | Pending | Pending | Pending | Pending |
| Stability observation completed | Pending | Pending | Pending | Pending |
| Cutover decision | Pending | Pending | Pending | Pending |

## Completion definition

GitHub UI-side validation is complete only when:

- repository, Actions, token, fork, retention, environment, and ruleset settings
  match this plan;
- the GitHub plan limitation and chosen approval model are explicitly recorded;
- OIDC trust is repository- and production-context-restricted and keyless;
- CI blocks a failing pull request and passes on the merged `main` SHA;
- controlled deployment and rollback produce verified retained evidence;
- the stability minimums pass; and
- the go/no-go review authorizes GitHub deployment cutover.

GitLab CI/CD must remain present and recoverable after this completion point
until a separately approved decommissioning plan is fully executed.

## GitHub documentation references

- [Managing GitHub Actions settings for a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)
- [Managing environments for deployment](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
- [Deployments and environments](https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
- [Creating rulesets for a repository](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository)
- [Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets)
- [Using workflow run logs](https://docs.github.com/en/actions/how-tos/monitor-workflows/use-workflow-run-logs)
- [Downloading workflow artifacts](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/download-workflow-artifacts)
