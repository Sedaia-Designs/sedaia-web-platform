package org.sedaiadesign.api.models.types

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class ContactType(val urlPrefix: String) {
  @SerialName("email")
  EMAIL("mailto:"),

  @SerialName("discord_user")
  DISCORD_USER("https://discord.com/users/"),

  @SerialName("telegram")
  TELEGRAM("https://t.me/")
}
