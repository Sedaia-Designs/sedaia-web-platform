package org.sedaiadesign.api

import io.ktor.server.netty.EngineMain

/**
 * Main entry point of the application, invoked when the server starts.
 * Delegates to Ktor's EngineMain to start the server engine.
 *
 * @param args Command-line arguments passed to the application.
 */
fun main(args: Array<String>) {
  EngineMain.main(args)
}
