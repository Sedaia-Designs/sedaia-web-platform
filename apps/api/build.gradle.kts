plugins {
  alias(libs.plugins.kotlin.jvm)
  alias(ktorLibs.plugins.ktor)
  alias(libs.plugins.kotlin.serialization)
}

application {
  mainClass = "io.ktor.server.netty.EngineMain"
}

kotlin {
  sourceSets.test {
    kotlin.srcDir("../../scripts/tests")
  }
}

val testRuntimeClasspath = sourceSets.test.get().runtimeClasspath

tasks.register("printTestRuntimeClasspath") {
  dependsOn(tasks.testClasses)
  doLast {
    println(testRuntimeClasspath.asPath)
  }
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
