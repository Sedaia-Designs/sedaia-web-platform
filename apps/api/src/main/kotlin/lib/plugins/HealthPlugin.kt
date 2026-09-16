package org.sedaiadesigns.lib.plugins

import dev.hayden.KHealth
import io.ktor.server.application.Application
import io.ktor.server.application.install

fun Application.configureKHealth() {
  install(KHealth) {
    healthCheckPath = "/health/live"
    readyCheckPath = "/health/ready"
  }
}
