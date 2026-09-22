# Phase 02 - Grant Build IAM

## Goal

Give the build identity only the capabilities required by `../../../../cloudbuild.yaml`.

## Commands

```sh
PROJECT_ID=sedaia-web-platform-api-508804
REGION=us-central1
BUILD_SA=sedaia-api-builder@${PROJECT_ID}.iam.gserviceaccount.com
RUNTIME_SA=sedaia-api-runtime@${PROJECT_ID}.iam.gserviceaccount.com

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${BUILD_SA}" \
  --role=roles/run.admin \
  --condition=None

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${BUILD_SA}" \
  --role=roles/logging.logWriter \
  --condition=None

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${BUILD_SA}" \
  --role=roles/storage.admin \
  --condition=None

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:${BUILD_SA}" \
  --role=roles/cloudbuild.builds.editor \
  --condition=None

gcloud artifacts repositories add-iam-policy-binding sedaia-repo \
  --project="$PROJECT_ID" --location="$REGION" \
  --member="serviceAccount:${BUILD_SA}" \
  --role=roles/artifactregistry.writer \
  --condition=None

gcloud iam service-accounts add-iam-policy-binding "$RUNTIME_SA" \
  --project="$PROJECT_ID" \
  --member="serviceAccount:${BUILD_SA}" \
  --role=roles/iam.serviceAccountUser \
  --condition=None
```

`--condition=None` explicitly creates an unconditional binding. Use it when
`gcloud` detects existing conditional bindings and asks which condition should
apply. It does not remove or modify the project's existing conditional
bindings. These permissions must remain available whenever the dedicated build
identity runs `cloudbuild.yaml`, so do not select or create an unrelated
time-based or resource condition at the prompt.

## Authorize the build submitter

The human or automation identity that submits a build with `--service-account`
also needs `roles/iam.serviceAccountUser` on `BUILD_SA`. Grant that binding to
the specific operator or automation principal, not to `allUsers` or
`allAuthenticatedUsers`.

For the currently authenticated human operator, inspect the account before
granting the binding:

```sh
OPERATOR_ACCOUNT="$(gcloud config get-value account)"
printf '%s\n' "$OPERATOR_ACCOUNT"
```

Confirm that the printed address is the intended Google user, then run:

```sh
gcloud iam service-accounts add-iam-policy-binding "$BUILD_SA" \
  --project="$PROJECT_ID" \
  --member="user:${OPERATOR_ACCOUNT}" \
  --role=roles/iam.serviceAccountUser \
  --condition=None
```

If the submitter is an automation service account instead of a human, use
`--member="serviceAccount:SERVICE_ACCOUNT_EMAIL"`; do not use the `user:`
prefix. GitHub Actions must use its dedicated OIDC deployment service account
as this principal when that workflow is configured.

## Verification

Export and review these policies before proceeding:

```sh
gcloud projects get-iam-policy "$PROJECT_ID" \
  --flatten='bindings[].members' \
  --filter="bindings.members:serviceAccount:${BUILD_SA}" \
  --format='table(bindings.role)'

gcloud artifacts repositories get-iam-policy sedaia-repo \
  --project="$PROJECT_ID" --location="$REGION"

gcloud iam service-accounts get-iam-policy "$RUNTIME_SA" \
  --project="$PROJECT_ID"

gcloud iam service-accounts get-iam-policy "$BUILD_SA" \
  --project="$PROJECT_ID"
```

## Exit criterion

The build identity can write images, write logs, create or update Cloud Run,
and attach only the intended runtime identity.

## Verification evidence

Verified on 2026-09-19 after applying the bindings.

- [x] Project policy grants the build identity these unconditional roles:
  - `roles/cloudbuild.builds.editor`
  - `roles/logging.logWriter`
  - `roles/run.admin`
  - `roles/storage.admin`
- [x] Artifact Registry repository `sedaia-repo` grants
  `roles/artifactregistry.writer` to the build identity.
- [x] Runtime identity `sedaia-api-runtime@...` grants
  `roles/iam.serviceAccountUser` to the build identity.
- [x] Build identity `sedaia-api-builder@...` grants
  `roles/iam.serviceAccountUser` to the current operator,
  `user:sakura.sedaia@gmail.com`.
- [ ] Add the dedicated GitHub OIDC deployment service account as another
  authorized build submitter after that account exists. Do not use the literal
  placeholder `SERVICE_ACCOUNT_EMAIL` or reuse the legacy deployer identity.

The runtime identity policy also contains a binding for the deleted principal
`gitlab-ci-deployer@...`. It grants no access to a live account and does not
block this phase. Remove the stale policy member separately during legacy
deployment cleanup rather than changing it as part of build authorization.

**Result:** The bindings required for a human-operated controlled Cloud Build
deployment are verified. Phase 02's build-identity permissions and exit
criterion are satisfied; GitHub automation authorization remains intentionally
deferred until its OIDC service account is created.
