require 'csv'
require 'JSON'

require "iiif_s3/version"
require "iiif_s3/builder"
require "iiif_s3/manifest"
require "iiif_s3/config"
require "iiif_s3/image_variant"
require "iiif_s3/thumbnail"
require "iiif_s3/image_tile"
require "iiif_s3/full_image"
require "iiif_s3/image_info"


module IiifS3

  # @return [String] The URI of the presentation context for the IIIF V.2
  PRESENTATION_CONTEXT  = "http://iiif.io/api/presentation/2/context.json"
  # @return [String] The URI of the image context for the IIIF V.2
  IMAGE_CONTEXT         = "http://iiif.io/api/image/2/context.json"
  # @return [String] The URI of the image protocol for IIIF
  IMAGE_PROTOCOL        = "http://iiif.io/api/image"
  # @return [String] The URI of the Level 0 profile for the IIIF V.2
  LEVEL_0               = "http://iiif.io/api/image/2/level0.json"

  
  # Validates a viewing direction string against the IIIF V.2 spec.
  #
  # According to v2 of the IIIF standards, there are only four valid viewing directions:
  # "left-to-right", "top-to-bottom”, "bottom-to-top" , and "right-to-left".  This
  #  returns true if the provided direction is one of these, and falst for anything else.
  #
  # @param [String] direction A viewing direction string
  #
  # @return [boolean] Is the provided string a valid viewing direction?
  # 
  def is_valid_viewing_direction(direction)
    direction == "left-to-right" ||
    direction == "top-to-bottom" ||
    direction == "bottom-to-top" ||
    direction == "right-to-left" 
  end

end

