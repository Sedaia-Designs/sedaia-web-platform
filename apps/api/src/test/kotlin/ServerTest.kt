package org.sedaiadesigns

import io.ktor.client.request.get
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
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

    val response = client.get("/v1/portfolio/")

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(ContentType.Application.Json, response.contentType()?.withoutParameters())
    assertTrue(response.bodyAsText().contains("\"owner\":\"Sakura Sedaia\""))
  }
}
