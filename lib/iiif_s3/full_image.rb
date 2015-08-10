
require "mini_magick"
require 'fileutils'

module IiifS3

  class FullImage < ImageVariant

    def resize(width, height); end

    def filestring
      "#{base_path}/full/full/0"
    end
  end
end