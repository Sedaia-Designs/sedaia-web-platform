import com.sun.net.httpserver.HttpExchange
import com.sun.net.httpserver.HttpServer
import java.net.InetSocketAddress
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.Path

private lateinit var scenario: String

private val validPortfolio = """
  {"programming":[{"title":"Project","description":"Description","projectPage":"https://example.test/project","sourceCode":"https://example.test/source","documentation":null}],"contact":[{"type":"email","label":"Email","icon":"envelope","value":"hello@example.test","href":"mailto:hello@example.test"}]}
""".trimIndent()

fun main(args: Array<String>) {
  scenario = args[0]
  val server = HttpServer.create(InetSocketAddress("127.0.0.1", 0), 0)
  server.createContext("/health/ready", ::readiness)
  server.createContext("/v1", ::api)
  server.start()
  Files.writeString(Path.of(args[1]), server.address.port.toString())
}

private fun readiness(exchange: HttpExchange) {
  if (scenario == "timeout") {
    Thread.sleep(6_000)
  }
  if (scenario == "readiness-non-200") {
    exchange.respond(503, "{\"status\":\"unavailable\"}")
  } else {
    exchange.respond(200, "{}")
  }
}

private fun api(exchange: HttpExchange) {
  if (exchange.requestURI.path == "/v1") {
    if (scenario == "legacy-metadata") {
      exchange.respond(404, "{\"error\":\"Not Found\"}")
    } else {
      exchange.respond(200, "{\"name\":\"Sedaia Designs API\",\"version\":\"v1\"}")
    }
    return
  }
  if (exchange.requestURI.path == "/v1/") {
    exchange.respond(200, "{\"name\":\"Sedaia Designs API\",\"version\":\"legacy\"}")
    return
  }

  val origin = exchange.requestHeaders.getFirst("Origin")
  if (origin == "https://example.com") {
    if (scenario == "invalid-cors") {
      exchange.respond(200, validPortfolio, origin)
    } else {
      exchange.respond(403, "{\"error\":\"Forbidden\"}")
    }
    return
  }

  when (scenario) {
    "portfolio-non-200" -> exchange.respond(500, "{\"error\":\"failed\"}", origin)
    "malformed-json" -> exchange.respond(200, "{not-json", origin)
    "missing-field" -> exchange.respond(200, "{\"programming\":[{\"title\":\"Project\"}],\"contact\":[]}", origin)
    "wrong-type" -> exchange.respond(200, "{\"programming\":\"not-an-array\",\"contact\":[]}", origin)
    else -> exchange.respond(200, validPortfolio, origin)
  }
}

private fun HttpExchange.respond(status: Int, body: String, origin: String? = null) {
  val bytes = body.toByteArray(StandardCharsets.UTF_8)
  responseHeaders.set("Content-Type", "application/json")
  origin?.let { responseHeaders.set("Access-Control-Allow-Origin", it) }
  sendResponseHeaders(status, bytes.size.toLong())
  responseBody.use { it.write(bytes) }
}
