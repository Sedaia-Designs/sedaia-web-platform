package org.sedaiadesign.api

import io.ktor.server.application.*
import io.ktor.server.routing.route
import io.ktor.server.routing.routing
import org.sedaiadesign.api.lib.configureServerPlugins
import org.sedaiadesign.api.routes.apiRoutes

fun Application.module() {
  configureServerPlugins()

  routing {
    route("/v1") {
      apiRoutes()
    }
  }
}
