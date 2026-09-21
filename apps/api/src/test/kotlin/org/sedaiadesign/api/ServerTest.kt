package org.sedaiadesign.api

import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.client.statement.bodyAsText
import io.ktor.http.ContentType
import io.ktor.http.HttpHeaders
import io.ktor.http.HttpStatusCode
import io.ktor.http.contentType
import io.ktor.server.testing.testApplication
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
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
  fun `versioned root endpoint describes the api`() = testApplication {
    configure()

    val response = client.get("/v1/")

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(ContentType.Application.Json, response.contentType()?.withoutParameters())
    assertEquals(
      mapOf("name" to "Sedaia Designs API", "version" to "v1"),
      Json.parseToJsonElement(response.bodyAsText()).jsonObject
        .mapValues { it.value.jsonPrimitive.content }
    )
  }

  @Test
  fun `portfolio endpoint responds with json`() = testApplication {
    configure()

    val response = client.get("/v1/portfolio/content")

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(ContentType.Application.Json, response.contentType()?.withoutParameters())

    val body = Json.parseToJsonElement(response.bodyAsText()).jsonObject
    assertEquals(setOf("programming", "contact"), body.keys)

    val projects = assertNotNull(body["programming"]).jsonArray

    assertEquals(2, projects.size)
    projects.forEach { projectElement ->
      val project = projectElement.jsonObject
      assertEquals(
        setOf("title", "description", "projectPage", "sourceCode", "documentation"),
        project.keys
      )
      listOf("title", "description", "projectPage", "sourceCode").forEach { field ->
        assertTrue(assertNotNull(project[field]).jsonPrimitive.content.isNotBlank())
      }
      assertTrue(assertNotNull(project["projectPage"]).jsonPrimitive.content.startsWith("https://"))
      assertTrue(assertNotNull(project["sourceCode"]).jsonPrimitive.content.startsWith("https://"))
    }
    assertEquals("Blender Development for Pycharm", projects[0].jsonObject["title"]!!.jsonPrimitive.content)
    assertEquals("Advanced Character Rig", projects[1].jsonObject["title"]!!.jsonPrimitive.content)

    val contacts = assertNotNull(body["contact"]).jsonArray
    assertEquals(3, contacts.size)
    contacts.forEach { contactElement ->
      val contact = contactElement.jsonObject
      assertEquals(setOf("type", "label", "icon", "value", "href"), contact.keys)
      contact.values.forEach { value -> assertTrue(value.jsonPrimitive.content.isNotBlank()) }
    }
  }

  @Test
  fun `portfolio endpoint allows the production portfolio origin`() = testApplication {
    configure()

    val origin = "https://sakura-sedaia.com"
    val response = client.get("/v1/portfolio/content") {
      header(HttpHeaders.Origin, origin)
    }

    assertEquals(HttpStatusCode.OK, response.status)
    assertEquals(origin, response.headers[HttpHeaders.AccessControlAllowOrigin])
  }

  @Test
  fun `portfolio endpoint does not allow an unknown origin`() = testApplication {
    configure()

    val response = client.get("/v1/portfolio/content") {
      header(HttpHeaders.Origin, "https://example.com")
    }

    assertEquals(HttpStatusCode.Forbidden, response.status)
    assertEquals(null, response.headers[HttpHeaders.AccessControlAllowOrigin])
  }
}
