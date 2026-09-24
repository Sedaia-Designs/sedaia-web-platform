package org.sedaiadesign.api.models.response

import kotlinx.serialization.Serializable

/**
 * Represents the metadata information about the API.
 *
 * This class provides details such as the name and version of the API.
 * It is primarily used to respond to requests for general API metadata,
 * typically at the root path of the API.
 *
 * @property name The name of the API.
 * @property version The current version of the API.
 */
@Serializable
data class ApiMetadataResponse(
  val name: String,
  val version: String
)
