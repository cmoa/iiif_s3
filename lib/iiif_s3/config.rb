module IiifS3
  
  # Config provides a data structure for holding the configuration settings
  # for the IiifS3 class.  
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  class Config

    # @return [String] The default URL to append to all IDs.
    DEFAULT_URL = "http://0.0.0.0"
    # @return [String] The name of the subdirectory where generated images live 
    DEFAULT_IMAGE_DIRECTORY_NAME = "images"
    # @return [String] The default path for writing generated image files
    DEFAULT_OUTPUT_DIRECTORY = "./build"
    # @return [Number] The default tile width/height in pixels
    DEFAULT_TILE_WIDTH = 512
    # @return [Array<Number>] The default tile scaling factors
    DEFAULT_TILE_SCALE_FACTORS = [1,2,4,8]
    # @return [Number] The default thumbnail size in pixels
    DEFAULT_THUMBNAIL_SIZE = 250    

    #
    # @!attribute [r] base_url
    #   @return [String] The protocol, domain, and port used for generating URIs.
    #   Defaults to {IiifS3::Config::DEFAULT_URL}
    attr_reader :base_url
    #
    # @!attribute [r] use_extensions
    #   @return [Boolean] Should generated IDs and files have a .json extension?
    #   Defaults to true
    attr_reader :use_extensions
    #
    # @!attribute [r] output_dir
    #   @return [String] The directory on the local file system where the output
    #     files should be saved
    #     Defaults to {IiifS3::Config::DEFAULT_OUTPUT_DIRECTORY}
    attr_reader :output_dir
    #
    # @!attribute [r] prefix
    #   @return [String] A prefix to be appended between the base URI and the id.
    #     Can be blank,and it will automatically prepend a slash if one is not
    #     provided.
    #   Defaults to ""
    attr_reader :prefix
    #
    # @!attribute [r] image_directory_name
    #   @return [String] The name of the directory/prefix where image files will be
    #   located.
    #   Defaults to IiifS3::Config::DEFAULT_IMAGE_DIRECTORY_NAME
    attr_reader :image_directory_name
    #
    # @!attribute [r] tile_width
    #   @return [Number] The width (and height) of each individual tile.
    #   Defaults to IiifS3::Config::DEFAULT_TILE_WIDTH
    attr_reader :tile_width
    #
    # @!attribute [r] tile
    #   @return [Array<Number>] An array of tile ratios to be uploaded.
    #   Defaults to IiifS3::Config::DEFAULT_TILE_SCALE_FACTORS
    attr_reader :tile_scale_factors
    #
    # @!attribute [r] variants
    #   @return [Hash] A Hash of key/value pairs.  Each key should be the name of a variant,
    #     each value the maximum pixel dimension of the longest side.
    #   Defaults to {}
    attr_reader :variants
    #
    # @!attribute [r] upload_to_s3
    #   @return [Boolean] Should the files that are created by automatically uploaded to Amazon S3?
    #   Defaults to false
    attr_reader :upload_to_s3

    # @!attribute [r] thumbnail_size
    #   @return [Number] The max width in pixels for a thumbnail image
    attr_reader :thumbnail_size

    # @!attribute [r] verbose
    #   @return [Bool] Should the program log information to the console?
    attr_reader :verbose
    alias :verbose? :verbose

    # @!attribute [r] s3
    #   @return [IiifS3::AmazonS3] the S3 object for this system
    attr_reader :s3


    # Initialize a new configuration option.
    #
    # @param [Hash] opts 
    # @option opts [Boolean] :upload_to_s3 if true, images and metadata will be
    #   uploaded to Amazon S3.  Defaults to False.
    # @option opts [Number] :tile_width The width in pixels for generated tiles.
    #   Defaults to {DEFAULT_TILE_WIDTH}
    # @option opts [Array<Number>] :tile_scale_factors An array of ratios for generated tiles.
    #   Defaults to {DEFAULT_TILE_SCALE_FACTORS}
    # @option opts [String] :image_directory_name The name of the subdirectory for actual
    #   image data. Defaults to {DEFAULT_IMAGE_DIRECTORY_NAME}
    # @option opts [String] :output_dir The name of the directory for generated files.
    #   image data. Defaults to {DEFAULT_OUTPUT_DIRECTORY}
    # @option opts [String] :base_url The base URL for the generated URIs.  Defaults to
    #   {DEFAULT_URL} if not auto-uploading to S3 and to the s3 bucket if upload_to_s3 is enabled. 
    # @option opts [Number] :thumbnail_size the size in pixels
    #   for the largest side of the thumbnail images.  Defaults to {DEFAULT_THUMBNAIL_SIZE}.
    # @option opts [Bool] :use_extensions (true) should files have exensions appended?  
    # @option opts [Bool] :verbose (false) Should debug information be printed to the console?  
    # @option opts [String] :prefix ("") a prefix (read: subdirectory) for the generated URIs.
    # @option opts [Hash{String: String}] :variants
    def initialize(opts = {})
      @upload_to_s3   = opts[:upload_to_s3] || false
      @s3             = IiifS3::AmazonS3.new if @upload_to_s3
      @tile_width     = opts[:tile_width]                 || DEFAULT_TILE_WIDTH
      @tile_scale_factors = opts[:tile_scale_factors]     || DEFAULT_TILE_SCALE_FACTORS
      @image_directory_name = opts[:image_directory_name] || DEFAULT_IMAGE_DIRECTORY_NAME
      @base_url       = opts[:base_url]                   || ( @upload_to_s3 ? @s3.bucket.url : DEFAULT_URL)
      @use_extensions = opts.fetch(:use_extensions, true) ## true
      @output_dir     = opts[:output_dir]                 || DEFAULT_OUTPUT_DIRECTORY
      @variants       = opts[:variants]                   || {}
      @thumbnail_size = opts[:thumbnail_size]             || DEFAULT_THUMBNAIL_SIZE
      @verbose        = opts.fetch(:verbose, false)       ## false
      @prefix         = opts[:prefix]                     || ""
      if @prefix.length > 0 && @prefix[0] != "/"
        @prefix = "/#{@prefix}" 
      end
    end


    # Compare two configuration files
    #
    # @param [IiifS3::Config] other_config The configuration file to compare
    #
    # @return [Bool] True if they are the same, false otherwise
    # 
    def ==(other_config)
      valid = true
      self.instance_variables.each do |v|
        valid &&= instance_variable_get(v) == other_config.instance_variable_get(v)
      end
      valid
    end
  end
end