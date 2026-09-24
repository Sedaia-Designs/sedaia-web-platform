package org.sedaiadesign.api.routes

import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import org.sedaiadesign.api.models.response.ApiMetadataResponse
import org.sedaiadesign.api.routes.portfolio.portfolioRoutes

/**
 * Configures the main API routes within the application.
 *
 * This function sets up routing for the following:
 * - The root path ("") of the API, which responds with metadata about the API, such as its name and version.
 * - Delegates the configuration of portfolio-related routes to the `portfolioRoutes` function.
 *
 * The root path returns an `ApiMetadataResponse` object that provides information about the API.
 * The metadata includes:
 * - `name`: The name of the API.
 * - `version`: The current version of the API.
 *
 * Subroutes under `/portfolio` are managed and defined in the `portfolioRoutes` function.
 */
fun Route.apiRoutes() {
  get("") {
    call.respond(
      ApiMetadataResponse(
        name = "Sedaia Designs API",
        version = "v1"
      )
    )
  }
  portfolioRoutes()
}
