module IiifS3
  class Config
    DEFAULT_URL = "http://localhost:8000"
    DEFAULT_IMAGE_STRING = "images"
    DEFAULT_TILE_WIDTH = 512
    attr_reader :base_uri, :use_extensions, :output_dir, :prefix, :image_directory_name, :tile_width, :tile_scale_factors
    def initialize(opts = {})

      @tile_width = opts[:tile_width] || DEFAULT_TILE_WIDTH
      @tile_scale_factors = opts[:tile_scale_factors] || [1,2,4,8]
      @image_directory_name = opts[:image_directory_name] || DEFAULT_IMAGE_STRING
      @base_uri = opts[:base_uri] || DEFAULT_URL
      @use_extensions = opts[:use_extensions].nil? ? true : opts[:use_extensions]
      @output_dir = opts[:output_dir] || "./build"
      @image_dir = @output_dir
      @prefix = opts[:prefix] || ""
      if @prefix.length > 0 && @prefix[0] != "/"
        @prefix = "/#{@prefix}" 
      end
    end

    def create_build_directories
      Dir.mkdir build_location("") unless Dir.exists?(build_location(""))
      imgdir = build_image_location("","").split("/")[0...-1].join("/")
      Dir.mkdir imgdir unless Dir.exists?(imgdir)
    end

    def build_location(id)
      "#{output_dir}#{prefix}/#{id}"
    end

    def build_image_location(id, page_number)
      "#{output_dir}#{prefix}/#{image_directory_name}/#{id}-#{page_number}"
    end

    def uri(id)
      "#{base_uri}#{prefix}/#{id}"
    end

    def image_uri(id, page_number)
      "#{base_uri}#{prefix}/#{image_directory_name}/#{id}-#{page_number}"
    end
  end
end