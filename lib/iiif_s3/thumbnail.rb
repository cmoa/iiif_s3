
require "mini_magick"
require 'fileutils'

module IiifS3

  class Thumbnail < ImageVariant

    MAX_WIDTH = 250
    MAX_HEIGHT = 250

    def resize(width, height)
      @image.resize "#{MAX_WIDTH}x#{MAX_HEIGHT}"
    end
    
  end
end