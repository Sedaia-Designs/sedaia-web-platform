package org.sedaiadesigns.lib

import io.ktor.server.application.Application
import org.sedaiadesigns.lib.plugins.configureCors
import org.sedaiadesigns.lib.plugins.configureKHealth
import org.sedaiadesigns.lib.plugins.configureSerialization

fun Application.configureServerPlugins() {
  configureCors()
  configureSerialization()
  configureKHealth()
}
