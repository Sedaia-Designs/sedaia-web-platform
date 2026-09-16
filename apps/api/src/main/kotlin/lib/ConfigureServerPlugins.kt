package org.sedaiadesigns.lib

import io.ktor.server.application.Application
import org.sedaiadesigns.lib.plugins.configureSerialization

fun Application.configureServerPlugins() {
  configureSerialization()
}