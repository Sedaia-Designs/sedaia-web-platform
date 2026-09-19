# Phase 05 - Configure the Main Branch Trigger

## Goal

Run the proven configuration for reviewed updates to `main`.

## Setup

First connect `Sedaia-Designs/sedaia-web-platform` to Cloud Build in project
`sedaia-web-platform-api-508804`. Repository authorization is an interactive
GitHub owner action and must be completed by a repository administrator.

After the GitHub connection is visible to Cloud Build, create the trigger:

```sh
PROJECT_ID=sedaia-web-platform-api-508804
REGION=us-central1
BUILD_SA=projects/${PROJECT_ID}/serviceAccounts/sedaia-api-builder@${PROJECT_ID}.iam.gserviceaccount.com

gcloud builds triggers create github \
  --project="$PROJECT_ID" \
  --region="$REGION" \
  --name=sedaia-api-main \
  --description='Build and deploy the Ktor API to Cloud Run from main' \
  --repo-owner=Sedaia-Designs \
  --repo-name=sedaia-web-platform \
  --branch-pattern='^main$' \
  --build-config=cloudbuild.yaml \
  --service-account="$BUILD_SA"
```

If the repository was connected through a second-generation repository
resource instead, create the trigger with that exact repository resource via
`gcloud builds triggers create repository-event`; do not create a duplicate
first-generation connection.

## Safeguards

- [ ] Require pull-request review and passing CI before merging into `main`.
- [ ] Exclude pull-request heads from the production trigger.
- [ ] Ensure only one trigger deploys the API for a given commit.
- [ ] Keep substitutions in the checked-in YAML unless an environment-specific
  override is intentionally documented.
- [ ] Run the trigger once from a harmless reviewed API change and compare its
  deployed configuration with the manual deployment.

## Exit criterion

A reviewed `main` commit produces exactly one successful regional build and one
healthy Cloud Run revision using the dedicated build identity.
