package org.sedaiadesign.api.routes

import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import org.sedaiadesign.api.models.response.ApiMetadataResponse
import org.sedaiadesign.api.routes.portfolio.portfolioRoutes

fun Route.apiRoutes() {
  get("/") {
    call.respond(
      ApiMetadataResponse(
        name = "Sedaia Designs API",
        version = "v1"
      )
    )
  }
  portfolioRoutes()
}
