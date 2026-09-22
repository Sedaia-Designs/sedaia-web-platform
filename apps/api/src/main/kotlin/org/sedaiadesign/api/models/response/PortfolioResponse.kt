package org.sedaiadesign.api.models.response

import kotlinx.serialization.Serializable
import org.sedaiadesign.api.models.response.portfolio.ContactResponse
import org.sedaiadesign.api.models.response.portfolio.ProgrammingResponse

@Serializable
data class PortfolioResponse(
  val programming: List<ProgrammingResponse>,
  val contact: List<ContactResponse>
  /*
    TODO: Add Render Response. This response will be implemented after the CDN system is setup and ready. The JSON response will be
      {
        "picture": {
          "src": "https://cdn.sedaia-designs.org/images/renders/<render.avif>",
          "description": string,
          "assets": map<string>
          "tags": list<string>
        }
      }
  */
)
