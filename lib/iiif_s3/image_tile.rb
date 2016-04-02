
require "mini_magick"
require 'fileutils'

module IiifS3

  #
  # Class ImageTile is a specific ImageVariant used when generating a 
  # stack of tiles suitable for Mirador-style zooming interfaces. Each
  # instance of ImageTile represents a single tile.
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  class ImageTile < ImageVariant

    #
    # Initializing this
    #
    # @param [Hash] data A Image Data object.
    # @param [IiifS3::Config] config The configuration object
    # @param [Hash<width: Number, height: Number, x Number, y: Number, xSize: Number, ySize: Number>] tile
    #    A hash of parameters that defines this tile.
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