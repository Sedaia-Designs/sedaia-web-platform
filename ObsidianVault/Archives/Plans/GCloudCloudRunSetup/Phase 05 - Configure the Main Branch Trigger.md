# Phase 05 - Configure the Main Branch Trigger

## Goal

Run the proven configuration for reviewed updates to `main`.

Tmux Session: configure-main-trigger
## Setup

First connect `Sedaia-Designs/sedaia-web-platform` to Cloud Build in project
`sedaia-web-platform-api-508804`. Repository authorization is an interactive
GitHub owner action and must be completed by a repository administrator.

- [x] Connect `Sedaia-Designs/sedaia-web-platform` to Cloud Build through the regional GitHub connection. Evidence recorded 2026-09-19.

After the GitHub connection is visible to Cloud Build, resolve the second-generation repository resource and create the trigger from it:

```sh
PROJECT_ID=sedaia-web-platform-api-508804
REGION=us-central1
CONNECTION=GitHub-Sedaia-Web-Platform
BUILD_SA=projects/${PROJECT_ID}/serviceAccounts/sedaia-api-builder@${PROJECT_ID}.iam.gserviceaccount.com
REPOSITORY_RESOURCE="$(gcloud builds repositories list \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --connection="$CONNECTION" \
  --filter='remoteUri=https://github.com/Sedaia-Designs/sedaia-web-platform.git' \
  --format='value(name)')"

test -n "$REPOSITORY_RESOURCE"

gcloud builds triggers create github \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --name=sedaia-api-main \
  --description='Build and deploy the Ktor API to Cloud Run from main' \
  --repository="$REPOSITORY_RESOURCE" \
  --branch-pattern='^main$' \
  --build-config=cloudbuild.yaml \
  --service-account="$BUILD_SA" \
  --include-logs-with-status
```

The `--repository` form is required for the linked second-generation repository. Do not use the first-generation `--repo-owner` and `--repo-name` form or create a duplicate repository connection.

## Repository connection evidence

**Recorded 2026-09-19.** The retained Cloud Console screenshot shows the enabled `GitHub-Sedaia-Web-Platform` connection in `us-central1`, with provider `GitHub`, provider authorization account `SakuraSedaia`, and linked repository `Sedaia-Designs/sedaia-web-platform`. This satisfies the repository-connection prerequisite, but does not by itself prove that the `main` trigger exists or has completed a successful build.

![[2026-09-19-cloud-build-github-repository-connection.png]]

Evidence SHA-256: `485842858b0bcc42038a58043bd02d9ad8434240e816013d364c28d978d0a4ab`

The screenshot is of the second-generation regional repository interface, so create the trigger with `gcloud builds triggers create github --repository="$REPOSITORY_RESOURCE"` using the exact linked repository resource in `us-central1`.

## Trigger creation evidence

**Recorded 2026-09-19 from tmux session `configure-main-trigger`.** The initial documented first-generation `--repo-owner` and `--repo-name` attempts failed twice with `FAILED_PRECONDITION: Repository mapping does not exist`. A third attempt created first-generation trigger `Github-Sedaia-Web-Platform` with ID `6c46ef49-6e2b-4484-9c79-6ef7f9b616cf`; it had not produced a build and was deleted after inspection.

The replacement trigger `sedaia-api-main` was created with ID `911d239d-69d9-4e1f-add6-27ef029c2469` using the existing second-generation repository resource `projects/sedaia-web-platform-api-508804/locations/us-central1/connections/GitHub-Sedaia-Web-Platform/repositories/Sedaia-Designs-sedaia-web-platform`. A post-creation description confirmed repository type `GITHUB`, push branch `^main$`, build file `cloudbuild.yaml`, build logs reported with status, and service account `sedaia-api-builder@sedaia-web-platform-api-508804.iam.gserviceaccount.com`. Regional and global trigger inventories showed exactly this one trigger and no duplicate global trigger.

## Safeguards

**Status: Complete. Deployment validation remains pending below.**

- [x] Require pull-request review and passing CI before merging into `main`. Verified 2026-09-20: the active `Protect main` ruleset requires approval of the most recent reviewable push by another authorized reviewer, requires the `Ktor API`, `Frontends`, and `API contract` checks, and requires pull-request branches to be up to date with `main`.
- [x] Exclude pull-request heads from the production trigger. Verified 2026-09-19: the trigger contains only push branch pattern `^main$` and no pull-request event configuration.
- [x] Ensure only one trigger deploys the API for a given commit. Verified 2026-09-19: one regional trigger and no global trigger exist; the manual GitHub Actions deployment remains a separately controlled break-glass concern until final cutover.
- [x] Keep substitutions in the checked-in YAML unless an environment-specific
  override is intentionally documented.

### Protect `main` before enabling automatic deployment

#### Existing ruleset evidence

**Recorded 2026-09-20.** The retained GitHub screenshot shows the `Protect main` ruleset is active, has an empty bypass list, and targets the default branch resolved to `main`. It visibly enables **Restrict deletions**, **Require linear history**, **Require a pull request before merging**, **Require status checks to pass**, and **Block force pushes**.

![[2026-09-20-github-main-ruleset.png]]

Evidence SHA-256: `cb925ec95051ff32f353b04d5581c9345b72478486b6b75b11baf0825edc6ee9`

This screenshot verifies that the core pull-request and status-check protections already exist. It does not expose the collapsed additional settings, so the expanded evidence below supplies the remaining configuration details.

**Expanded settings recorded 2026-09-20.** The retained screenshot confirms **Required approvals** is `0`, **Dismiss stale pull request approvals when new commits are pushed** is enabled, **Require approval of the most recent reviewable push** is enabled, **Require conversation resolution before merging** is enabled, and squash is the only allowed merge method. GitHub defines approval of the most recent reviewable push as requiring at least one other authorized reviewer to approve the latest changes, so the review safeguard is satisfied despite the general approval count being zero. The screenshot also confirms that `Ktor API`, `Frontends`, and `API contract` are required status checks.

![[2026-09-20-github-main-ruleset-expanded.png]]

Evidence SHA-256: `3511c5f21ef1525a9893d6ba9fb957553c9514ee0583b40eb404a3e3c17e650f`

**Strict status-check confirmation recorded 2026-09-20.** The repository administrator confirmed that **Require branches to be up to date before merging** is enabled. This closes the remaining ruleset hardening item and ensures a pull request is tested against current `main` before merge.

**Required-check source options recorded 2026-09-20.** The retained selector screenshot confirms GitHub does not offer **GitHub Actions** as an expected source in this ruleset. The available app-specific choices are unrelated producers, including Copilot, GitHub Merge Queue, Google Cloud Build, and Google Cloud Developer Connect. Keep `Ktor API`, `Frontends`, and `API contract` set to **Any source**; selecting one of those apps would incorrectly require that app to emit the GitHub Actions job check and could leave pull requests permanently blocked.

![[2026-09-20-github-required-check-source-options.png]]

Evidence SHA-256: `59bc00a21239677934ec2981e4db535e44cded754e10efe5841cc5588b190ab0`

Use the following procedure when recreating or hardening the ruleset:

1. Open `Sedaia-Designs/sedaia-web-platform` on GitHub and go to **Settings → Rules → Rulesets → New ruleset → New branch ruleset**.
2. Name the ruleset `main-protection`, set **Enforcement status** to **Active**, and leave the bypass list empty. If an administrator bypass is operationally required, add only the narrowest suitable role or team and document its owner and emergency-use conditions in this note.
3. Under **Target branches**, choose **Add a target → Include default branch**. Confirm the evaluated target is `main`; do not use a broad pattern that also protects feature branches.
4. Enable **Restrict deletions** and **Block force pushes** so the deployment branch cannot be removed or rewritten.
5. Enable **Require a pull request before merging** and enable **Dismiss stale pull request approvals when new commits are pushed**, **Require approval of the most recent reviewable push**, and **Require conversation resolution before merging**. Setting **Required approvals** to `1` makes the minimum explicit; the recorded configuration instead uses `0` together with approval of the most recent reviewable push, which still requires another authorized reviewer to approve the latest changes. Do not enable **Require review from Code Owners** until a reviewed `CODEOWNERS` file exists in the repository.
6. Enable **Require status checks to pass** and add `Ktor API`, `Frontends`, and `API contract`. These are the exact job names emitted by `.github/workflows/ci.yml`; required workflow checks are identified by job name rather than workflow name. Leave the source as **Any source** because GitHub Actions is not offered in this repository's source selector, and do not select Google Cloud Build or another unrelated app.
7. Enable **Require branches to be up to date before merging**. This ensures the reviewed head is tested against the current `main` before the push can start the production Cloud Build trigger.
8. Do not add `sedaia-api-main` as a required pull-request check. It is a post-merge deployment trigger restricted to pushes on `main`, so it cannot satisfy a pre-merge requirement.
9. Save the ruleset and reopen it to confirm that its enforcement status is **Active**, its target resolves to `main`, and all three required checks are present.

If one or more CI checks are absent from the selector, first open a harmless pull request and allow `.github/workflows/ci.yml` to run successfully, then return to the ruleset and add the checks. Do not substitute similarly named checks or assign an unrelated app as their expected source.

Validate enforcement with a disposable branch and harmless pull request. Confirm that the pull request cannot merge before one approval, while any required check is pending or failing, while a review conversation is unresolved, or after a new commit makes the approval stale. After all three checks pass, the conversation is resolved, the branch is current, and a fresh approval exists, merge the pull request and retain the pull-request URL as evidence. Also attempt a non-destructive direct update only if it can be safely rejected before sending content; otherwise verify the rule through GitHub's ruleset evaluation rather than creating an unwanted commit.

Record the ruleset name, ruleset URL or ID, activation date, required check names, bypass actors, validation pull-request URL, and reviewer in this section, then mark the safeguard complete. GitHub's authoritative references are [Creating rulesets for a repository](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository), [Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets), and [Troubleshooting rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules).

### Restrict the trigger to merged `main` commits

Use `--branch-pattern='^main$'` and do not configure `--pull-request-pattern`. A branch-pattern trigger reacts to pushes to the exact `main` branch; pull-request head updates do not match it. After creation, verify the event configuration and repository resource:

```sh
gcloud builds triggers describe sedaia-api-main \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --format='yaml(name,repositoryEventConfig,filename,serviceAccount,substitutions)'
```

The output must identify the linked second-generation repository, branch regex `^main$`, `cloudbuild.yaml`, and the dedicated builder service account. Stop and correct the trigger if a pull-request event is present.

### Prevent duplicate production deployments

Inventory every regional and global trigger before and after creation:

```sh
gcloud builds triggers list \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --format='table(name,id,repositoryEventConfig.repository,repositoryEventConfig.push.branch,filename,disabled)'

gcloud builds triggers list \
  --project="$PROJECT_ID" \
  --region=global \
  --format='table(name,id,github.owner,github.name,github.push.branch,filename,disabled)'
```

There must be only one enabled trigger capable of deploying `sedaia-api` from a `main` push. `.github/workflows/deploy-api.yml` can also submit `cloudbuild.yaml` manually; once the automatic trigger is accepted as the canonical deployment path, disable or remove that workflow, or retain it only as a documented break-glass path that cannot run for the same commit during normal releases.

### Keep configuration ownership in `cloudbuild.yaml`

Do not pass `_REGION`, `_ARTIFACT_REPOSITORY`, `_SERVICE`, or `_RUNTIME_SERVICE_ACCOUNT` through `--substitutions` when creating or running the production trigger. Their production values already live in `cloudbuild.yaml`. If an override becomes necessary, record its name, value, owner, reason, and expiration in this phase before applying it, then verify the trigger with the `describe` command above.

### Validate the first automatic deployment

- [x] Run the trigger once from a harmless reviewed API change and compare its deployed configuration with the manual deployment. Verified 2026-09-20 from merged pull request #1.

Merge one harmless, reviewed API change after all required CI checks pass. Record the merge commit SHA, then confirm Cloud Build produced exactly one build for it:

```sh
COMMIT_SHA=<merged-commit-sha>

gcloud builds list \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --filter="substitutions.COMMIT_SHA=$COMMIT_SHA" \
  --format='table(id,status,createTime,finishTime,substitutions.TRIGGER_NAME,results.images)'
```

Require one row with status `SUCCESS` and trigger name `sedaia-api-main`. Record the build ID, image digest, deployed revision, builder identity, and verification output. Compare the resulting Cloud Run service account, ingress, port, scaling, resources, concurrency, timeout, startup probe, liveness probe, labels, image digest, and traffic allocation with the manually verified Phase 04 deployment. Run `scripts/verify-api-deployment.sh` against the generated Cloud Run URL and do not complete this phase unless the new revision is ready, receives 100 percent of traffic, and passes the full smoke test.

#### First automatic deployment evidence

**Verified 2026-09-20.** Pull request #1 merged `dev` into `main` as commit `87c6411d982d766bd251fe2a8def7c91a9180a77`. Exactly one regional build matched that commit: build `ab3fbd1d-b7dc-4621-aec0-af7a95d45ace`, created by trigger `sedaia-api-main`, completed with status `SUCCESS` from 14:51:19 UTC through 14:58:26 UTC. The `test-api`, `build-image`, `push-image`, and `deploy-cloud-run` steps all succeeded.

![[2026-09-20-first-automatic-cloud-build.png]]

Evidence SHA-256: `3c7fdf37fdbc81d3ede30a1b00b94f5a1ea455d67a8f70e65db9e96507147356`

- [x] Builder identity: `sedaia-api-builder@sedaia-web-platform-api-508804.iam.gserviceaccount.com`.
- [x] Image tag: `us-central1-docker.pkg.dev/sedaia-web-platform-api-508804/sedaia-repo/sedaia-api:ab3fbd1d-b7dc-4621-aec0-af7a95d45ace`.
- [x] Image digest: `sha256:deb6241027cbe4f661bb2a3a86b5f18a13813b7147f4f1d1e20cb8fe5d47f9d2`.
- [x] Ready revision: `sedaia-api-00002-z9z`, labeled with the matching build ID and `managed-by=cloud-build`.
- [x] Runtime identity: `sedaia-api-runtime@sedaia-web-platform-api-508804.iam.gserviceaccount.com`.
- [x] Traffic: the latest-created and latest-ready revision are both `sedaia-api-00002-z9z`, receiving 100 percent.
- [x] Configuration matches the manually verified deployment: ingress `all`, port `8080`, minimum instances `0` by default, maximum instances `3`, CPU `1`, memory `512Mi`, concurrency `40`, timeout `30s`, and the documented startup and liveness probes.
- [x] `scripts/verify-api-deployment.sh` passed at 15:09:33 UTC against `https://sedaia-api-gf5626wkfq-uc.a.run.app`, including readiness, portfolio HTTP/JSON, and CORS for `https://sakura-sedaia.com`.

**Result:** Phase 05 is complete. The reviewed merge commit produced exactly one successful regional build and one healthy Cloud Run revision using the dedicated build and runtime identities.

## Exit criterion

A reviewed `main` commit produces exactly one successful regional build and one
healthy Cloud Run revision using the dedicated build identity.
