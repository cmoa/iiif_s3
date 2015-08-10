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


module IiifS3
  PRESENTATION_CONTEXT  = "http://iiif.io/api/presentation/2/context.json"
  IMAGE_CONTEXT         = "http://iiif.io/api/image/2/context.json"
  IMAGE_PROTOCOL        = "http://iiif.io/api/image"
  LEVEL_0             = "http://iiif.io/api/image/2/level0.json"

  def is_valid_viewing_direction(dir)
    dir == "left-to-right" ||
    dir == "top-to-bottom”" ||
    dir == "bottom-to-top" ||
    dir == "right-to-left" 
  end

end
