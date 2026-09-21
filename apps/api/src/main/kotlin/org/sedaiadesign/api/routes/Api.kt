package org.sedaiadesign.api.routes

import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import io.ktor.server.routing.route

import org.sedaiadesign.api.models.response.ApiMetadataResponse
import org.sedaiadesign.api.models.response.PortfolioResponse
import org.sedaiadesign.api.models.response.portfolio.ContactResponse
import org.sedaiadesign.api.models.response.portfolio.ProgrammingResponse
import org.sedaiadesign.api.models.types.ContactIconType
import org.sedaiadesign.api.models.types.ContactType

fun Route.apiRoutes() {
  get("/") {
    call.respond(
      ApiMetadataResponse(
        name = "Sedaia Designs API",
        version = "v1"
      )
    )
  }
  route("/portfolio") {
    get("/content") {
      call.respond(
        PortfolioResponse(
          programming = listOf(
            ProgrammingResponse(
              title = "Blender Development for Pycharm",
              description = """
                **Blender Development** is a plugin originally developed for PyCharm. The original idea is based on the [Blender Development](https://github.com/JacquesLucke/blender_vscode) extension by Jacques Lucke for Visual Studio Code, of which my plugin's core Python runtime is forked from. The plugin is developed in Kotlin, and is heavily integrated into the Intellij Platform SDK, granting it more advanced and integrated features including:

                - Managed Blender Installs
                - Access to Pycharm's advanced debugging tools
                - Python Intellisense Stub installations

                The plugin is currently at version 1.0.0 Beta 3, with the main development being focused on refinement and security in preparation for a full 1.0.0 release.
              """.trimIndent(),
              projectPage = "https://www.sedaia-designs.org/projects/blender-development",
              sourceCode = "https://gitlab.com/sedaia-designs/blender_pycharm",
              documentation = "https://docs.blender-development.sakura-sedaia.tech/"
            ),
            ProgrammingResponse(
              title = "Advanced Character Rig",
              description = """
                **Sakura Advanced Character Rig (SACR)** is a Blender rig and toolkit for creating Minecraft-style character renders. The project brings its independently released components together in one repository, including:

                - Character rig releases, source assets, and supporting files
                - Sakura Rig Utilities for rig and skin management workflows
                - Reusable Blender scripts for specialized, one-off tasks

                The rig is actively maintained across Blender versions, while Sakura Rig Utilities is in early development as the future home for discovering, downloading, and importing SACR rigs directly in Blender.
              """.trimIndent(),
              projectPage = "https://www.sedaia-designs.org/projects/sakura-character-rig",
              sourceCode = "https://gitlab.com/sedaia-designs/advanced-character-rig",
              documentation = "https://docs.sakura-sedaia.com"
            )
          ),
          contact = listOf(
            ContactResponse(
              type = ContactType.EMAIL,
              label = "Email",
              icon = ContactIconType.ENVELOPE,
              value = "email@sakura-sedaia.com"
            ),
            ContactResponse(
              type = ContactType.DISCORD_USER,
              label = "Discord",
              icon = ContactIconType.DISCORD,
              value = "705154478382252053"
            ),
            ContactResponse(
              type = ContactType.TELEGRAM,
              label = "Telegram",
              icon = ContactIconType.TELEGRAM,
              value = "SakuraSedaia"
            )
          )
        )
      )
    }
  }
}
