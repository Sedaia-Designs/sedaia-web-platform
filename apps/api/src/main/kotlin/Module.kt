package org.sedaiadesigns

import io.ktor.server.application.*
import io.ktor.server.routing.route
import io.ktor.server.routing.routing
import org.sedaiadesigns.lib.configureServerPlugins
import org.sedaiadesigns.routes.apiRoutes

fun Application.module() {
  configureServerPlugins()

  routing {
    route("/v1") {
      apiRoutes()
    }
  }
}
