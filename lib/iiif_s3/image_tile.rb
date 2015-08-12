
require "mini_magick"
require 'fileutils'

module IiifS3

  class ImageTile < ImageVariant

    def initialize(data, config, tile)
      @tile = tile
      super(data, config)
    end

    protected
    
    def resize(width=nil,height=nil)
      @image.combine_options do |img|
        img.crop "#{@tile[:width]}x#{@tile[:height]}+#{@tile[:x]}+#{@tile[:y]}"
        img.resize "#{@tile[:xSize]}x#{@tile[:ySize]}"
      end
    end
    
    def region
      "#{@tile[:x]},#{@tile[:y]},#{@tile[:width]},#{@tile[:height]}"
    end

    def filestring
      "/#{region}/#{@tile[:xSize]},/0"
    end

  end
end