---
tags:
  - failure
  - gradle
  - app-engine
  - configuration-cache
status: diagnosed
date: 2026-09-18
---

# App Engine Gradle Configuration Cache Failure

## Summary

Running `appengineDeploy` with Gradle 9.5.1 fails before deployment because the
Google App Engine Gradle plugin is not compatible with Gradle's configuration
cache. This is a build-tool integration failure, not a Ktor application,
`app.yaml`, Google Cloud authentication, or deployed-service failure.

The repository enables the configuration cache globally:

```properties
org.gradle.configuration-cache=true
```

The API module applies:

```kotlin
id("com.google.cloud.tools.appengine") version "2.8.0"
```

The failed configuration-cache entry was discarded, so it cannot be reused.

## Observed failures

The task graph reports three violations from tasks supplied by the App Engine
plugin:

| Task | Violation | Plugin implementation cause |
| --- | --- | --- |
| `:apps:api:downloadCloudSdk` | Calls `Task.project` during execution | Its `@TaskAction` calls `getProject()` while constructing `DownloadCloudSdkTaskConsoleListener` |
| `:apps:api:appengineStage` | Retains a non-serializable `DefaultProject` | The task holds `StageAppYamlExtension`, which has a `Project` field |
| `:apps:api:appengineDeploy` | Retains a non-serializable `DefaultProject` | The task holds `DeployExtension`, which has a `Project` field |

The first reported build failure is the runtime manifestation of the
`downloadCloudSdk` violation. The second reported failure is Gradle's aggregate
configuration-cache validation result. They share the same root cause.

The plugin-resolution rule in `settings.gradle.kts` selects the requested
module but does not introduce these violations. The API module's `stage` and
`deploy` values also do not cause them.

## Version check

The locally cached `2.8.7` plugin bytecode was inspected as a possible upgrade
target. It still:

- calls `getProject()` inside `DownloadCloudSdkTask.downloadCloudSdkAction()`;
- stores `Project` in `StageAppYamlExtension`; and
- stores `Project` in `DeployExtension`.

Consequently, upgrading from `2.8.0` to `2.8.7` alone is not expected to make
these tasks configuration-cache compatible. Any future release should be
verified against all three conditions before treating an upgrade as the fix.

## Potential solutions

### 1. Disable the configuration cache only for deployment

Run the deployment invocation with:

```shell
./gradlew :apps:api:appengineDeploy --no-configuration-cache
```

This is the lowest-risk operational workaround. Normal compilation and test
invocations can continue using the configuration cache, while the incompatible
third-party deployment task runs using Gradle's ordinary lifecycle.

Tradeoff: every deployment invocation performs configuration normally. This is
usually a small cost relative to SDK staging and network deployment.

### 2. Declare the App Engine tasks incompatible in build logic

Gradle provides `Task.notCompatibleWithConfigurationCache(...)` for tasks that
cannot yet satisfy the cache requirements. The affected App Engine tasks could
be marked with a documented reason from repository build logic.

This makes the incompatibility explicit and reduces reliance on every operator
or workflow remembering a command-line switch. It should first be tested with
the exact Gradle version and complete deployment graph because the plugin
creates several related tasks dynamically.

Tradeoff: deployment still cannot benefit from the configuration cache, and
repository build logic becomes coupled to third-party task names.

### 3. Disable the configuration cache globally

Removing or disabling `org.gradle.configuration-cache=true` would allow the
legacy plugin lifecycle everywhere.

This is simple but broad. It forfeits configuration-cache benefits for builds,
tests, and unrelated modules, so it is less desirable than a deployment-only
exception unless other plugins also prove incompatible.

### 4. Move deployment outside the App Engine Gradle plugin

Use Gradle only to build the deployable artifact, then stage and deploy with
the Google Cloud CLI from a script or CI workflow. This removes the legacy
plugin tasks from the deployment graph and makes build and deployment concerns
independent.

Tradeoff: the staging contract currently supplied by `appengineStage` must be
made explicit and verified, including the fat JAR name, `app.yaml`, working
directory, ignore rules, deployment flags, and authentication behavior.

This is the strongest long-term option if the plugin remains incompatible or
is no longer maintained at the pace required by current Gradle versions.

### 5. Patch or replace the plugin implementation

A maintained fork or upstream contribution could make the tasks cache-safe by
removing execution-time `Project` access and replacing extension objects held
by tasks with serializable, declarative Gradle properties and services.

This addresses the root cause and could preserve an all-Gradle deployment
workflow. It is also the highest-maintenance option and should include
configuration-cache integration tests for stage, SDK download, and deploy.

### 6. Upgrade only to a release verified as compatible

An upgrade is appropriate if a later plugin release removes all three known
violations. Version number recency alone is insufficient: locally available
`2.8.7` retains them.

## Recommended decision order

1. Use a deployment-only configuration-cache exception to unblock deployment.
2. Correct and verify the artifact staging path described below.
3. Decide whether the Gradle plugin remains the desired long-term deployment
   interface.
4. If it does, track or implement an upstream-compatible plugin release.
5. If it does not, establish and verify a direct `gcloud` deployment path.

## Separate latent staging issue

The current configuration contains:

```kotlin
setArtifact("/build/libs/${project.name}-all.jar")
```

Because the string begins with `/`, it denotes an absolute path rooted at
`/build`, not the API module's `build` directory. This did not cause the
configuration-cache failure because execution stopped earlier. Once the cache
problem is bypassed, it may cause `appengineStage` to fail to find the artifact.

Before deployment is considered healthy, verify the actual fat-JAR task output
and configure the artifact through a project-relative or layout/provider-based
path.

## Verification criteria for a future change

- The full deployment graph runs without configuration-cache validation errors,
  or the deployment-only incompatibility is intentional and documented.
- `appengineStage` consumes the artifact actually produced by the API build.
- The staged directory contains the expected JAR and `app.yaml`.
- A non-production deployment completes with the intended Google Cloud project
  and version resolution.
- Normal build and test tasks retain configuration-cache reuse if a scoped
  workaround is selected.

## References

- [Gradle configuration-cache requirements](https://docs.gradle.org/9.5.1/userguide/configuration_cache_requirements.html)
- [Gradle configuration cache](https://docs.gradle.org/9.5.1/userguide/configuration_cache.html)
- `apps/api/build.gradle.kts`
- `gradle.properties`
- `gradle/wrapper/gradle-wrapper.properties`
- `build/reports/problems/problems-report.html`
- `build/reports/configuration-cache/`

