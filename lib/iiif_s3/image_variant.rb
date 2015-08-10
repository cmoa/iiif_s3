
require "mini_magick"
require 'fileutils'

module IiifS3

  class ImageVariant

    attr_reader :image, :path, :uri, :base_path

    include MiniMagick

    def width
      @image.width
    end

    def height
      @image.height
    end

    def mime_type
      @image.mime_type
    end

    def filestring
      "#{base_path}/full/#{width},#{height}/0"
    end

    def resize(width, height)
      @image.resize "#{width}x#{height}"
    end

    def initialize(data, config, width = 0, height = 0)

      # open image
      @image = Image.open(data["img_path"])
      resize(width, height)
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