package org.sedaiadesign.api

import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.server.testing.testApplication
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

class ServerTest {

  @Test
  fun `liveness endpoint responds with json`() = testApplication {
    configure()

    val response = client.get("/health/live")

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(ContentType.Application.Json, response.contentType()?.withoutParameters())
    assertEquals("{}", response.bodyAsText())
  }

  @Test
  fun `readiness endpoint responds with json`() = testApplication {
    configure()

    val response = client.get("/health/ready")

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(ContentType.Application.Json, response.contentType()?.withoutParameters())
    assertEquals("{}", response.bodyAsText())
  }

  @Test
  fun `versioned root endpoint responds`() = testApplication {
    configure()

    assertEquals(HttpStatusCode.OK, client.get("/v1/").status)
  }

  @Test
  fun `portfolio endpoint responds with json`() = testApplication {
    configure()

    val response = client.get("/v1/portfolio/content")

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(ContentType.Application.Json, response.contentType()?.withoutParameters())
    assertTrue(response.bodyAsText().contains("\"owner\":\"Sakura Sedaia\""))
  }

  @Test
  fun `portfolio endpoint allows the production portfolio origin`() = testApplication {
    configure()

    val origin = "https://sakura-sedaia.com"
    val response = client.get("/v1/portfolio/") {
      header(HttpHeaders.Origin, origin)
    }

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(origin, response.headers[HttpHeaders.AccessControlAllowOrigin])
  }

  @Test
  fun `portfolio endpoint does not allow an unknown origin`() = testApplication {
    configure()

    val response = client.get("/v1/portfolio/") {
      header(HttpHeaders.Origin, "https://example.com")
    }

    assertEquals(HttpStatusCode.Forbidden, response.status)
    assertEquals(null, response.headers[HttpHeaders.AccessControlAllowOrigin])
  }
}
