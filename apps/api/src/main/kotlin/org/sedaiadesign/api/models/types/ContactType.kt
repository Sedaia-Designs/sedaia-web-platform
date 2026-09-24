package org.sedaiadesign.api.models.types

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Enumerates the possible types of contact methods and their associated URL prefixes.
 *
 * Each contact type is mapped to a specific prefix that is used to construct
 * a complete contact URL. This enumeration is typically used in the context of
 * representing different ways to contact an individual or organization, such as
 * email, Discord, or Telegram.
 *
 * The contact types are:
 * - EMAIL: Representing an email address, prefixed with "mailto:".
 * - DISCORD_USER: Representing a Discord user, prefixed with "https://discord.com/users/".
 * - TELEGRAM: Representing a Telegram user, prefixed with "https://t.me/".
 */
@Serializable
enum class ContactType(val urlPrefix: String) {
  @SerialName("email")
  EMAIL("mailto:"),

  @SerialName("discord_user")
  DISCORD_USER("https://discord.com/users/"),

  @SerialName("telegram")
  TELEGRAM("https://t.me/")
}
