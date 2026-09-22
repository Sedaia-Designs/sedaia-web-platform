package org.sedaiadesign.api.models.response.portfolio

import kotlinx.serialization.Serializable
import org.sedaiadesign.api.models.types.ContactIconType
import org.sedaiadesign.api.models.types.ContactType

@Serializable
data class ContactResponse(
  val type: ContactType,
  val label: String,
  val icon: ContactIconType = ContactIconType.GLOBE,
  val value: String
) {
  val href = type.urlPrefix + value
}
