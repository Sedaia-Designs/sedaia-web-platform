package org.sedaiadesign.api

import io.ktor.server.application.*
import io.ktor.server.routing.route
import io.ktor.server.routing.routing
import org.sedaiadesign.api.lib.configureServerPlugins
import org.sedaiadesign.api.routes.apiRoutes

/**
 * Configures the application's main module by setting up server plugins and defining routing endpoints.
 *
 * The `module` function initializes server-level configurations and routes to handle incoming API requests.
 *
 * - Invokes `configureServerPlugins` to set up CORS, serialization, and health check plugins.
 * - Defines a `/v1` API route that delegates to `apiRoutes`, which includes various subroutes for the API.
 */

fun Application.module() {
  configureServerPlugins()

  routing {
    route("/v1") {
      apiRoutes()
    }
  }
}
