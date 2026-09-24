package org.sedaiadesign.api.routes.portfolio

import io.ktor.server.response.respond
import io.ktor.server.routing.Route
import io.ktor.server.routing.get
import io.ktor.server.routing.route
import org.sedaiadesign.api.models.response.PortfolioResponse
import org.sedaiadesign.api.models.response.portfolio.ContactResponse
import org.sedaiadesign.api.models.response.portfolio.ProgrammingResponse
import org.sedaiadesign.api.models.types.ContactIconType
import org.sedaiadesign.api.models.types.ContactType

/**
 * Configures the portfolio-related API routes.
 *
 * This function defines routes under the `/portfolio` path, with the following endpoints:
 * - `/content`: Handles HTTP GET requests and responds with a `PortfolioResponse` containing
 *   detailed information about programming projects and contact methods.
 *
 * The `/content` response includes:
 * - A list of programming project details, encapsulated in `ProgrammingResponse`, which includes:
 *   - Project title
 *   - Project description
 *   - Links to the project page, source code, and documentation
 * - A list of contact methods, encapsulated in `ContactResponse`, which includes:
 *   - Contact type (e.g., Email, Discord User, Telegram)
 *   - Label and icon type for the contact method
 *   - The contact value (e.g., email address, Discord ID)
 *
 * Example programming projects returned in the response include:
 * - Blender Development for PyCharm: A PyCharm plugin for Blender scripting and debugging.
 * - Sakura Advanced Character Rig: A Blender rig for Minecraft-style renders.
 *
 * The included contact methods provide ways to connect to the associated organization or individual
 * via platforms like Discord, Telegram, and Email.
 *
 * The data models used in the response are:
 * - `PortfolioResponse`: Represents the overall structure of the response, containing
 *   programming projects and contact methods.
 * - `ProgrammingResponse`: Represents individual programming project details.
 * - `ContactResponse`: Represents individual contact methods and their associated metadata.
 */
fun Route.portfolioRoutes() {
  route("/portfolio") {
    get("/content") {
      call.respond(
        PortfolioResponse(
          // Descriptions are rendered with a TypeScript adaptation of ymfpfp's original JavaScript
          // Markdown parser: https://github.com/ymfpfp/markdown-parser/tree/main
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
