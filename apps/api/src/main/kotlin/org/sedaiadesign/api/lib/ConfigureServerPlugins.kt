package org.sedaiadesign.api.lib

import io.ktor.server.application.Application
import org.sedaiadesign.api.lib.plugins.configureCors
import org.sedaiadesign.api.lib.plugins.configureKHealth
import org.sedaiadesign.api.lib.plugins.configureSerialization

/**
 * Configures the application's server plugins.
 *
 * This function sets up and installs the necessary plugins to enhance server functionality.
 * The configurations include:
 *
 * - **CORS (Cross-Origin Resource Sharing)**: Defines a set of allowed hosts for secure HTTP communication.
 * - **Serialization**: Enables JSON serialization and deserialization for API requests and responses.
 * - **Health Check**: Provides endpoints to monitor the application's liveness and readiness status.
 *
 * This method is typically invoked during the application startup to ensure all required plugins
 * are properly configured and ready for handling incoming requests.
 */
fun Application.configureServerPlugins() {
  configureCors()
  configureSerialization()
  configureKHealth()
}
