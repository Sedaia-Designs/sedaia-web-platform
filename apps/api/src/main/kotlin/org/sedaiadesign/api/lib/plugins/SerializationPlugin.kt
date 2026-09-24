package org.sedaiadesign.api.lib.plugins

import io.ktor.server.application.Application
import io.ktor.server.application.install
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation

/**
 * Configures JSON serialization and deserialization for the application.
 *
 * This method installs the ContentNegotiation plugin with Kotlinx's JSON support,
 * enabling the application to process incoming and outgoing data in JSON format.
 *
 * This is essential for building APIs that rely on structured data exchange
 * and ensures compatibility with JSON-based client applications.
 */
fun Application.configureSerialization() {
  install(ContentNegotiation) {
    json()
  }
}
