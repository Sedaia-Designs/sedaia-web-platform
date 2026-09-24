package org.sedaiadesign.api.models.response.portfolio

import kotlinx.serialization.Serializable
import org.sedaiadesign.api.models.types.ContactIconType
import org.sedaiadesign.api.models.types.ContactType

/**
 * Represents a response structure for a contact method.
 *
 * This data class encapsulates details about a contact method, including its type, label,
 * associated icon, and contact value. It also constructs a hyperlink (`href`) based on the
 * contact type's predefined URL prefix and the provided value.
 *
 * This is typically used to represent different means of communication, such as
 * email, Discord, or Telegram, in various API responses.
 *
 * @property type The type of contact method, defined by the [ContactType] enum.
 * @property label A human-readable label describing the contact method.
 * @property icon The type of icon associated with the contact method, defined by the [ContactIconType] enum. Defaults to `ContactIconType.GLOBE`.
 * @property value The specific value of the contact method (e.g., email address, username).
 * @property href A generated hyperlink constructed from the contact type's URL prefix and value.
 */
@Serializable
data class ContactResponse(
  val type: ContactType,
  val label: String,
  val icon: ContactIconType = ContactIconType.GLOBE,
  val value: String
) {
  val href = type.urlPrefix + value
}
