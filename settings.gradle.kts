pluginManagement {
  repositories {
    gradlePluginPortal()
    mavenCentral()
    maven("https://redirector.kotlinlang.org/maven/ktor-eap")
  }
  resolutionStrategy {
    eachPlugin {
      if (requested.id.id.startsWith("com.google.cloud.tools.appengine")) {
        useModule("com.google.cloud.tools:appengine-gradle-plugin:${requested.version}")
      }
    }
  }
}

plugins {
  id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

dependencyResolutionManagement {
  @Suppress("UnstableApiUsage")
  repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)

  @Suppress("UnstableApiUsage")
  repositories {
    mavenCentral()
    maven("https://jitpack.io")
  }

  versionCatalogs {
    create("ktorLibs").from("io.ktor:ktor-version-catalog:3.5.2")
  }
}

rootProject.name = "sedaia-web-platform"

include(":apps:api")
