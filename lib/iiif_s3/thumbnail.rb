require "mini_magick"
require 'fileutils'

module IiifS3

  #
  # Class Thumbnail provides a specific variant of an image file used for the thumbnail links
  # within the metadata.  It will generate a consistent sized version based on a max width
  # and height.  By default, it generates images at 250px on the longest size.
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  class Thumbnail < ImageVariant

    # Initialize a new thumbnail.  
    #
    # @param [hash] data The image data object
    # @param [Hash] config The configuration hash
    # @param [Integer] max_width The maximum width of the thumbnail
    # @param [Integer] max_height The maximum height of the thumbnail
    # 
    def initialize(data, config, max_width=nil, max_height = nil)
      @max_width = max_width || config.thumbnail_size
      @max_height = max_height || config.thumbnail_size
      super(data,config)
    end

    protected

    def resize(width, height)
      @image.resize "#{@max_width}x#{@max_height}"
    end
    
  end
end