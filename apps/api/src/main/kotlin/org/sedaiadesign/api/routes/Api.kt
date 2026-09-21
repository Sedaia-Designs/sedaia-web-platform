package org.sedaiadesign.api.routes

import io.ktor.server.response.respond
import io.ktor.server.response.respondText
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import io.ktor.server.routing.route

import org.sedaiadesign.api.models.response.PortfolioResponse

fun Route.apiRoutes() {
  get("/") {
    call.respondText("Hello Ktor!")
  }
  route("/portfolio") {
    get("/") {
      call.respond(
        PortfolioResponse(
          owner = "Sakura Sedaia",
          headline = "Novice Web Engineer and 3D Artist",
          projects = emptyList()
        )
      )
    }
  }
}