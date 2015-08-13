
require "mini_magick"
require 'fileutils'

module IiifS3

  #
  # Class ImageVariant represents a single image file within a manifest.
  # 
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  class ImageVariant
    include MiniMagick

    #
    # Initializing an ImageVariant will create the actual image file 
    # on the file system.  
    # 
    # To initialize an image, you will need the 
    # data hash to have an "id", a "image_path", and a "page_number".
    #
    # @param [Hash] data A Image Data object.
    # @param [IiifS3::Config] config The configuration object
    # @param [Number] width the desired width of this object in pixels
    # @param [Number] height the desired height of this object in pixels
    # @raise IiifS3::Error::InvalidImageData
    #  
    def initialize(data, config, width = nil, height = nil)

      # Validate input data
      if data["id"].nil? || data["id"].to_s.empty?
        raise IiifS3::Error::InvalidImageData, "Each image needs an ID" 
      elsif data["image_path"].nil? || data["image_path"].to_s.empty?
        raise IiifS3::Error::InvalidImageData, "Each image needs an path." 
      elsif data["page_number"].nil? || data["page_number"].to_s.empty?
        raise IiifS3::Error::InvalidImageData, "Each image needs an page number." 
      elsif not File.exists? data["image_path"]
        raise IiifS3::Error::InvalidImageData, "there is no image at that path." 
      end

      # open image
      begin
        @image = Image.open(data["image_path"])
      rescue MiniMagick::Invalid => e
        raise IiifS3::Error::InvalidImageData, "Cannot read this image file: #{data["image_path"]}. #{e}"
      end

      resize(width, height)
      @image.format "jpg"

      @id = "#{config.image_uri(data['id'],data['page_number'])}"
      @uri =  "#{id}#{filestring}/default.jpg"

      # Create the on-disk version of the file
      path = "#{config.build_image_location(data["id"],data["page_number"])}#{filestring}"
      FileUtils::mkdir_p path
      filename = "#{path}/default.jpg"
      @image.write filename unless File.exists? filename
    end


    # @!attribute [r] uri
    # @return [String] The URI for the jpeg image
    attr_reader :uri

    #
    # @!attribute [r] id
    #   @return [String] The URI for the variant.  
    attr_reader :id


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

    #
    # Get the MIME Content-Type of the image. 
    #
    # @return [String] the MIME Content-Type (typically "image/jpeg")
    # 
    def mime_type
      @image.mime_type
    end

    protected

    def region
      "full"
    end

    def resize(width, height)
      @image.resize "#{width}x#{height}"
    end

    def filestring
      "/#{region}/#{width},/0"
    end

  end
end