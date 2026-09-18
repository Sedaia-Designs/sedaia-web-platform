import com.google.cloud.tools.gradle.appengine.appyaml.AppEngineAppYamlExtension

plugins {
  alias(libs.plugins.kotlin.jvm)
  alias(ktorLibs.plugins.ktor)
  alias(libs.plugins.kotlin.serialization)
  id("com.google.cloud.tools.appengine") version "2.8.0"
}

configure<AppEngineAppYamlExtension> {
  stage {
    setArtifact("./build/libs/${project.name}-all.jar")
  }
  deploy {
    version = "GCLOUD_CONFIG"
    projectId = "GCLOUD_CONFIG"
  }
}

application {
  mainClass = "io.ktor.server.netty.EngineMain"
}

dependencies {
  implementation(ktorLibs.server.config.yaml)
  implementation(ktorLibs.server.core)
  implementation(ktorLibs.server.cors)
  implementation(ktorLibs.server.netty)
  implementation(ktorLibs.server.statusPages)

  // Content Serialization
  implementation(ktorLibs.server.contentNegotiation)
  implementation(ktorLibs.serialization.kotlinx.json)

  // Logs
  implementation(libs.logback.classic)
  implementation(libs.hayden.khealth)

  // Database
  implementation("org.jetbrains.exposed:exposed-core:1.3.1")
  implementation("org.jetbrains.exposed:exposed-r2dbc:1.3.1")
  implementation("com.h2database:h2:2.4.240")
  implementation("io.r2dbc:r2dbc-h2:1.1.0.RELEASE")

  // Testing
  testImplementation(kotlin("test"))
  testImplementation(ktorLibs.server.testHost)
}
