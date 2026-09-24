package org.sedaiadesign.api.models.response

import kotlinx.serialization.Serializable
import org.sedaiadesign.api.models.response.portfolio.ContactResponse
import org.sedaiadesign.api.models.response.portfolio.ProgrammingResponse


/**
 * Represents the response structure for portfolio-related data, which includes details
 * about programming projects and contact methods.
 *
 * This class serves as a data model encapsulating information about a list of programming
 * projects and available contact methods. It is serialized for JSON responses.
 *
 * @property programming A list of programming project details, where each project is
 * represented using the `ProgrammingResponse` data class.
 * @property contact A list of available contact methods, where each contact method is
 * represented using the `ContactResponse` data class.
 *
 * Note: Future versions will include an additional `RenderResponse` property to support
 * CDN-rendered assets. This property is currently under development and not yet implemented.
 */
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
