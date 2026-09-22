package org.sedaiadesign.api.models.response

import kotlinx.serialization.Serializable

@Serializable
data class ApiMetadataResponse(
  val name: String,
  val version: String
)
