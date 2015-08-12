
require "mini_magick"
require 'fileutils'

module IiifS3

  #
  # Class FullImage is a standard image variant that does not resize the image at all.
  class FullImage < ImageVariant

    protected
    
    def filestring
      "/full/full/0"
    end

    def resize(width, height); end

  end
end