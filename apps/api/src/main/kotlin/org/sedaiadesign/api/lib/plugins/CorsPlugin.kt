package org.sedaiadesign.api.lib.plugins

import io.ktor.server.application.Application
import io.ktor.server.application.install
import io.ktor.server.plugins.cors.routing.CORS

/**
 * Configures Cross-Origin Resource Sharing (CORS) for the application.
 *
 * This method installs the CORS plugin to control and enable cross-origin HTTP requests
 * based on a predefined set of allowed hosts. It specifically defines the following:
 *
 * - `sakura-sedaia.com` and `www.sakura-sedaia.com` for portfolio access over HTTPS.
 * - `sedaia-designs.org` and `www.sedaia-designs.org` for business access over HTTPS.
 *
 * This configuration is essential for securing the application by allowing only
 * predefined external domains to interact with the server.
 */
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
