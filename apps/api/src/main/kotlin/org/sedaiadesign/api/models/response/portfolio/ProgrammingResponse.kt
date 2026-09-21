package org.sedaiadesign.api.models.response.portfolio

import kotlinx.serialization.Serializable

@Serializable
data class ProgrammingResponse(
  val title: String,
  val description: String,
  val projectPage: String,
  val sourceCode: String,
  val documentation: String? = null
)
