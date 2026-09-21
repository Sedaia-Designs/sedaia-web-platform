package org.sedaiadesign.api.lib

import io.ktor.server.application.Application
import org.sedaiadesign.api.lib.plugins.configureCors
import org.sedaiadesign.api.lib.plugins.configureKHealth
import org.sedaiadesign.api.lib.plugins.configureSerialization

fun Application.configureServerPlugins() {
  configureCors()
  configureSerialization()
  configureKHealth()
}
