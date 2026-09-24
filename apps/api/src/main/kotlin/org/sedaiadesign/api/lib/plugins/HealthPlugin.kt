package org.sedaiadesign.api.lib.plugins

import dev.hayden.KHealth
import io.ktor.server.application.Application
import io.ktor.server.application.install

/**
 * Configures health check endpoints for the application.
 *
 * This method installs the KHealth plugin to provide health monitoring endpoints
 * that can be used to assess the application's liveness and readiness status.
 *
 * The following paths are defined:
 * - `/health/live`: Endpoint for checking the application's liveness.
 * - `/health/ready`: Endpoint for checking the application's readiness.
 *
 * These endpoints are typically consumed by monitoring systems or load balancers
 * to ensure the application is running and capable of handling traffic.
 */
fun Application.configureKHealth() {
  install(KHealth) {
    healthCheckPath = "/health/live"
    readyCheckPath = "/health/ready"
  }
}
