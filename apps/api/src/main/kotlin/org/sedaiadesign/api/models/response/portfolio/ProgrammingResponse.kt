package org.sedaiadesign.api.models.response.portfolio

import kotlinx.serialization.Serializable

@Serializable
data class PortfolioProjectResponse(
  val id: String,
  val title: String,
  val description: String? = null
)
