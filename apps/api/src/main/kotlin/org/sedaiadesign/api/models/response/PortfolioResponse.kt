package org.sedaiadesign.api.models.response

import kotlinx.serialization.Serializable

@Serializable
data class PortfolioResponse(
  val owner: String,
  val headline: String,
  val projects: List<PortfolioProjectResponse>
)
