import org.jetbrains.kotlin.gradle.dsl.KotlinJvmProjectExtension

plugins {
  alias(libs.plugins.kotlin.jvm) apply false
  alias(ktorLibs.plugins.ktor) apply false
}

val projectGroup = providers.gradleProperty("projectGroup").get()
val projectVersion = providers.gradleProperty("projectVersion").get()
val javaVersion = libs.versions.java.get().toInt()

allprojects {
  group = projectGroup
  version = projectVersion
}

subprojects {
  pluginManager.withPlugin("org.jetbrains.kotlin.jvm") {
    extensions.configure<KotlinJvmProjectExtension> {
      jvmToolchain(javaVersion)
    }
  }

  tasks.withType<Test>().configureEach {
    useJUnitPlatform()
  }
}
