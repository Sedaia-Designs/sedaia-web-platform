package org.sedaiadesign.api.models.types

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Represents the icons associated with different contact methods.
 *
 * Constants use Kotlin's uppercase snake case convention. Each [SerialName]
 * matches the corresponding key in the TypeScript icon registry.
 */
@Serializable
enum class ContactIconType {
  @SerialName("discord")
  DISCORD,

  @SerialName("github")
  GITHUB,

  @SerialName("youtube")
  YOUTUBE,

  @SerialName("deviantart")
  DEVIANTART,

  @SerialName("codeberg")
  CODEBERG,

  @SerialName("gumroad")
  GUMROAD,

  @SerialName("instagram")
  INSTAGRAM,

  @SerialName("pinterest")
  PINTEREST,

  @SerialName("reddit")
  REDDIT,

  @SerialName("twitch")
  TWITCH,

  @SerialName("twitter")
  TWITTER,

  @SerialName("patreon")
  PATREON,

  @SerialName("telegram")
  TELEGRAM,

  @SerialName("pixiv")
  PIXIV,

  @SerialName("envelope")
  ENVELOPE,

  @SerialName("globe")
  GLOBE
}
