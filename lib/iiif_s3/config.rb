module IiifS3
  class Config
    DEFAULT_URL = "http://localhost:8000"
    DEFAULT_IMAGE_STRING = "images"
    DEFAULT_TILE_WIDTH = 512
    attr_reader :base_uri, :use_extensions, :output_dir, :prefix, :image_directory_name, :tile_width, :tile_scale_factors, :variants, :s3
    def initialize(opts = {})

      @s3 = IiifS3::AmazonS3.new
      @tile_width = opts[:tile_width] || DEFAULT_TILE_WIDTH
      @tile_scale_factors = opts[:tile_scale_factors] || [1,2,4,8]
      @image_directory_name = opts[:image_directory_name] || DEFAULT_IMAGE_STRING
      @base_uri = opts[:base_uri] || @s3.bucket.url
      @use_extensions = opts[:use_extensions].nil? ? true : opts[:use_extensions]
      @output_dir = opts[:output_dir] || "./build"
      @image_dir = @output_dir
      @variants = opts[:variants] || { "reference" => 600, "access" => 1200}
      @prefix = opts[:prefix] || ""
      if @prefix.length > 0 && @prefix[0] != "/"
        @prefix = "/#{@prefix}" 
      end
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

    def add_file_to_s3(filename)
      key = filename.gsub(output_dir,"")
      key = key[1..-1] if key[0] == "/"
      if File.extname(filename) == ".json" || File.extname(filename)  == ""
        @s3.add_json(key,filename)
      elsif  File.extname(filename) == ".jpg" 
        @s3.add_image(key,filename)
      else
        raise "Cannot identify file type!"
      end
    end

    def ==(other_config)
      valid = true
      self.instance_variables.each do |v|
        next if v == :@s3
        valid &&= instance_variable_get(v) == other_config.instance_variable_get(v)
      end
      valid
    end

  end
end