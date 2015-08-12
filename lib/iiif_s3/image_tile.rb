
require "mini_magick"
require 'fileutils'

module IiifS3

  class ImageTile < ImageVariant

    attr_reader :region


    def initialize(data, config, tile)

      # open image
      @image = Image.open(data["img_path"])
      @tile = tile

      #above is redundant, and should be refactored

      @image.combine_options do |img|
        img.crop "#{tile[:width]}x#{tile[:height]}+#{tile[:x]}+#{tile[:y]}"
        img.resize "#{tile[:xSize]}x#{tile[:ySize]}"
      end

      @region = "#{tile[:x]},#{tile[:y]},#{tile[:width]},#{tile[:height]}"

      #below is redundant, and should be refactored.

      @image.format "jpg"

      @path = "#{config.build_image_location(data["id"],data["page_number"])}#{filestring}"
      @uri =  "#{config.image_uri(data['id'],data['page_number'])}#{filestring}/default.jpg"

      FileUtils::mkdir_p path
      filename = "#{path}/default.jpg"
      @image.write filename unless File.exists? filename
      filename
    end

    protected
    
    def filestring
      "/#{region}/#{@tile[:xSize]},/0"
    end

  end
end