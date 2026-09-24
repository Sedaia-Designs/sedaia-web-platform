package org.sedaiadesign.api.models.response.portfolio

import kotlinx.serialization.Serializable

/**
 * Represents the response structure for detailing programming-related information.
 *
 * This data class encapsulates metadata for individual programming projects or resources.
 * It is commonly used in responses related to portfolio or project management APIs,
 * providing a structured format for sharing programming-related content.
 *
 * @property title The title or name of the programming resource or project.
 * @property description A brief description or summary of the programming project or resource.
 * @property projectPage A URL or link to the project page, providing more details.
 * @property sourceCode A URL or link to the source code repository or location.
 * @property documentation A URL or link to the documentation related to the project or resource.
 */
@Serializable
data class ProgrammingResponse(
  val title: String,
  val description: String,
  val projectPage: String,
  val sourceCode: String,
  val documentation: String
)
