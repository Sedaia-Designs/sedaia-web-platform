# Phase 03 - Align the Build Configuration

## Goal

Make the checked-in build configuration compatible with the dedicated build
identity and ensure the upload contains no local output or secrets.

## Repository changes

- [x] Add the following beside `dynamicSubstitutions` in
  `../../../cloudbuild.yaml`:

  ```yaml
  options:
    dynamicSubstitutions: true
    logging: CLOUD_LOGGING_ONLY
  ```

- [x] Keep the target substitutions set to `us-central1`, `sedaia-repo`,
  `sedaia-api`, and the `sedaia-api-runtime` identity.
- [x] Keep `${BUILD_ID}` as the image tag so manual and triggered builds both
  produce immutable names.
- [x] Confirm deployment includes `--allow-unauthenticated`, `--ingress=all`,
  port `8080`, startup/readiness behavior, liveness behavior, memory, CPU,
  concurrency, timeout, and bounded instance count.
- [x] Confirm `.gcloudignore` excludes `.git`, Gradle output, frontend output,
  dependency directories, local notes, and secret files.

### Verify the Cloud Run deployment settings

Run these commands from the repository root. First inspect the complete deploy
step:

```sh
sed -n '/- id: deploy-cloud-run/,/^images:/p' cloudbuild.yaml
```

Check every required runtime, health, resource, and scaling argument:

```sh
for argument in \
  '--allow-unauthenticated' \
  '--ingress=all' \
  '--port=8080' \
  '--min-instances=0' \
  '--max-instances=3' \
  '--memory=512Mi' \
  '--cpu=1' \
  '--concurrency=40' \
  '--timeout=30s' \
  '--startup-probe=httpGet.path=/health/ready,httpGet.port=8080,initialDelaySeconds=0,timeoutSeconds=2,periodSeconds=5,failureThreshold=12' \
  '--liveness-probe=httpGet.path=/health/live,httpGet.port=8080,initialDelaySeconds=10,timeoutSeconds=2,periodSeconds=30,failureThreshold=3'
do
  if rg --fixed-strings --quiet -- "$argument" cloudbuild.yaml; then
    printf 'PASS  %s\n' "$argument"
  else
    printf 'FAIL  %s\n' "$argument"
  fi
done
```

Every line must report `PASS`. Then confirm the deployment target, runtime
identity, and immutable build tag:

```sh
for value in \
  '--image=${_REGION}-docker.pkg.dev/${PROJECT_ID}/${_ARTIFACT_REPOSITORY}/${_SERVICE}:${BUILD_ID}' \
  '--project=${PROJECT_ID}' \
  '--region=${_REGION}' \
  '--platform=managed' \
  '--service-account=${_RUNTIME_SERVICE_ACCOUNT}'
do
  if rg --fixed-strings --quiet -- "$value" cloudbuild.yaml; then
    printf 'PASS  %s\n' "$value"
  else
    printf 'FAIL  %s\n' "$value"
  fi
done
```

Finally, inspect the substitutions used by those arguments:

```sh
sed -n '/^substitutions:/,/^steps:/p' cloudbuild.yaml
```

The expected values are:

```yaml
_REGION: us-central1
_ARTIFACT_REPOSITORY: sedaia-repo
_SERVICE: sedaia-api
_RUNTIME_SERVICE_ACCOUNT: sedaia-api-runtime@${PROJECT_ID}.iam.gserviceaccount.com
```

Mark the deployment-settings checklist item complete only when both automated
checks contain no `FAIL` lines and the substitutions match these values.

## Validation

```sh
./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon
gcloud meta list-files-for-upload
git diff --check
```

Review every path printed by `list-files-for-upload`. It must not contain
`.env`, credentials, `.git`, `node_modules`, `../../../.gradle`, or any `build` folder.

## Exit criterion

The repository build passes locally, Cloud Build logs have an allowed storage
destination, and the upload manifest contains only expected source/config files.

## Verification evidence

Verified on 2026-09-19.

- [x] `cloudbuild.yaml` uses `CLOUD_LOGGING_ONLY` with dynamic substitutions.
- [x] Target substitutions resolve to `us-central1`, `sedaia-repo`,
  `sedaia-api`, and the `sedaia-api-runtime` service account.
- [x] The build and deploy image references use `${BUILD_ID}`.
- [x] All automated deployment-argument checks reported `PASS`, including
  public invocation, ingress, port, startup and liveness probes, resources,
  concurrency, timeout, and the zero-to-three instance range.
- [x] `./gradlew :apps:api:check :apps:api:buildFatJar --no-daemon` completed
  successfully.
- [x] `gcloud meta list-files-for-upload` was reviewed after adding exclusions
  for environment files, key material, credential JSON, IDE run configuration,
  and macOS metadata.
- [x] The final upload inventory contains the root build/container
  configuration, API sources and tests, Gradle wrapper, workflows, scripts, and
  operations documentation. It contains no `.env`, credential, key, `.git`,
  `.gradle`, `node_modules`, build-output, frontend-source, Obsidian, or local
  IDE files.
- [x] `git diff --check` passes.

**Result:** Phase 03 is complete. The checked-in Cloud Build configuration is
compatible with the dedicated build identity, and its upload context contains
only the expected source and configuration files.
