
require "mini_magick"
require 'fileutils'

module IiifS3

  class ImageTile < ImageVariant

    attr_reader :region

    def filestring
      "#{base_path}/#{region}/#{width},/0"
    end

    def initialize(data, config, tile)

      # open image
      @image = Image.open(data["img_path"])

      #above is redundant, and should be refactored

      @image.combine_options do |img|
        img.crop "#{tile[:width]}x#{tile[:height]}+#{tile[:x]}+#{tile[:y]}"
        img.resize "#{tile[:xSize]}x#{tile[:ySize]}"
      end

      @region = "#{tile[:x]},#{tile[:y]},#{tile[:width]},#{tile[:height]}"

      #below is redundant, and should be refactored.

      @image.format "jpg"

      @base_path = "#{config.prefix}/#{data["id"]}"
      @path = "#{config.output_dir}#{filestring}"
      @uri = "#{config.base_uri}#{filestring}/default.jpg"

      FileUtils::mkdir_p path
      filename = "#{path}/default.jpg"
      @image.write filename unless File.exists? filename
      filename
    end
  end
end