package org.sedaiadesign.api.models.types

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

/**
 * Enumerates the types of contact icons available for use in representing various contact methods.
 *
 * Each constant in this enum represents an icon type that corresponds to a specific
 * contact platform or method. These icons can be used in user interfaces, API responses,
 * or other representations to visually indicate the type of contact method being referenced.
 *
 * The supported contact icon types include:
 * - DISCORD: Represents a Discord user or server.
 * - GITHUB: Represents a GitHub profile or repository.
 * - YOUTUBE: Represents a YouTube channel or video link.
 * - DEVIANTART: Represents a DeviantArt profile or artwork.
 * - CODEBERG: Represents a Codeberg profile or repository.
 * - GUMROAD: Represents a Gumroad profile or storefront.
 * - INSTAGRAM: Represents an Instagram profile or content.
 * - PINTEREST: Represents a Pinterest board, profile, or pin.
 * - REDDIT: Represents a Reddit profile or subreddit.
 * - TWITCH: Represents a Twitch channel or user.
 * - TWITTER: Represents a Twitter profile or tweet.
 * - PATREON: Represents a Patreon profile or campaign.
 * - TELEGRAM: Represents a Telegram user or channel.
 * - PIXIV: Represents a Pixiv profile or artwork.
 * - ENVELOPE: Represents a generic email or message icon.
 * - GLOBE: Represents a generic web or URL link icon.
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
