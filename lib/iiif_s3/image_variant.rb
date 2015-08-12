
require "mini_magick"
require 'fileutils'

module IiifS3

  class ImageVariant

    #
    # @!attribute [r] image
    # @return [MiniMagick::Image] The image itself
    attr_reader :image
 
    #
    # @!attribute [r] path
    # @return [String] the path on disk for this image
    attr_reader :path
 
    #
    # @!attribute [r] uri
    # @return [String] The URI for the image data
    attr_reader :uri
 
    #
    # @!attribute [r] base_path
    # @return [String] The base URI for the image representation
    attr_reader :base_path


    attr_reader :base_uri, :id

    include MiniMagick

    # Get the image width
    #
    #
    # @return [Number] The width of the image in pixels
    def width
      @image.width
    end

    # Get the image height
    #
    #
    # @return [Number] The height of the image in pixels
    def height
      @image.height
    end

    def mime_type
      @image.mime_type
    end


    def initialize(data, config, width = 0, height = 0)

      # open image
      @image = Image.open(data["img_path"])
      resize(width, height)
      @image.format "jpg"

      @path = "#{config.build_image_location(data["id"],data["page_number"])}#{filestring}"
      @id = "#{config.image_uri(data['id'],data['page_number'])}"
      @base_uri = "#{id}#{filestring}"
      @uri =  "#{@base_uri}/default.jpg"
      FileUtils::mkdir_p path
      filename = "#{path}/default.jpg"
      @image.write filename unless File.exists? filename
      filename
    end

    protected

    def resize(width, height)
      @image.resize "#{width}x#{height}"
    end

    def filestring
      "/full/#{width},#{height}/0"
    end


  end
end