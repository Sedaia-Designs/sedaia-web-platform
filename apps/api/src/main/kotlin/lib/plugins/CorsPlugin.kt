package org.sedaiadesigns.lib.plugins

import io.ktor.server.application.Application
import io.ktor.server.application.install
import io.ktor.server.plugins.cors.routing.CORS

fun Application.configureCors() {
  install(CORS) {
    // Portfolio
    allowHost("sakura-sedaia.com", schemes = listOf("https"))
    allowHost("www.sakura-sedaia.com", schemes = listOf("https"))

    // Business
    allowHost("sedaia-designs.org", schemes = listOf("https"))
    allowHost("www.sedaia-designs.org", schemes = listOf("https"))
  }
}
