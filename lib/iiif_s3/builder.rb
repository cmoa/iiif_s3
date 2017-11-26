require_relative "utilities"
require 'pathname'

module IiifS3
  class Builder

    include Utilities::Helpers

    HEADER_VAL = 'filename'
    
    #
    # @!attribute [r] data
    #   @return [Array<Hash>] The raw data computed for the given set of images
    attr_reader :data

    #
    # @!attribute [r] manifests
    #   @return [Array<Hash>] The manifest hashes for this configuration
    attr_accessor :manifests

    # @!attribute [r] config
    #   @return [IiifS3::Config] The configuration object
    attr_reader :config

    # Initialize the builder.
    #
    # @param [Hash] config an optional configuration object.
    # @see IiifS3::Config
    # @return [Void]
    # 
    def initialize(config = {})
      @manifests = []
      @config = IiifS3::Config.new(config)
    end


    #
    # Load data into the IIIF builder. 
    # 
    # This will load the data, perform some basic verifications on it, and sort
    # it into proper order.
    #
    # @param [Array<ImageRecord>, ImageRecord] data 
    #   Either a single ImageRecord or an Array of ImageRecords.
    # @raise [IiifS3::Error::InvalidImageData] if any of the data does 
    #   not pass the validation checks
    # 
    # @return [Void]
    # 
    def load(data)
      @data = [data].flatten # handle hashes and arrays of hashes

      # validate
      @data.each  do |image_record| 
        raise IiifS3::Error::InvalidImageData, "Image record #{image_record.inspect} is not an ImageRecord" unless image_record.is_a? ImageRecord
        raise IiifS3::Error::InvalidImageData, "Image record #{image_record.inspect} does not have an ID and/or a page number" if image_record.id.nil? || image_record.page_number.nil?
      end
    end


    #
    # Take the loaded data and generate all the files.
    #
    # @param [Boolean] force_image_generation Generate images even if they already exist
    #
    # @return [Void]
    # 
    def process_data(force_image_generation=false)
      return nil if @data.nil? # do nothing without data.
      @manifests = []

      resources = {}
      @data.each do |image_record|
        
        # image generation
        # 
        # It attempts to load the info files and skip generation — not currently working.
        info_file = image_info_file_name(image_record)
        if (File.exist?(info_file) && !force_image_generation)
          puts "skipping #{info_file}" if @config.verbose?
          image_record.variants = load_variants(info_file)
        else
          image_record.variants = generate_variants(image_record, @config)
          generate_tiles(image_record, @config)
          generate_image_json(image_record, @config)
        end
        # Save the image info for the manifest
        resources[image_record.id] ||= []
        resources[image_record.id].push image_record
      end

      # Generate the manifests
      resources.each do |key, val|
        manifests.push generate_manifest(val, @config) 
      end

      generate_collection
    end    

    def generate_collection(label="top")
      collection = Collection.new(label,@config)
      manifests.each{|m| collection.add_manifest(m)}
      collection.save
    end

    # Creates the required directories for exporting to the file system.
    #
    # @return [Void]
    def create_build_directories
    root_dir =  generate_build_location("")
      Dir.mkdir root_dir unless Dir.exists?(root_dir)
      img_dir = generate_image_location("","").split("/")[0...-1].join("/")
      Dir.mkdir img_dir unless Dir.exists?(img_dir)
    end

    # Load data into the IIIF server from a CSV
    #
    # @param [String] csv_path Path to the CSV file containing the image data
    #
    # @return [Void]
    # @todo Fix this to use the correct data format!
    # 
    def load_csv(csv_path)
      raise Error::InvalidCSV unless File.exist? csv_path
      begin
        vals = CSV.read(csv_path)
      rescue CSV::MalformedCSVError
        raise Error::InvalidCSV
      end  

      raise Error::BlankCSV if vals.length == 0
      raise Error::InvalidCSV if vals[0].length != 3

      # remove optional header
      vals.shift if vals[0][0] == HEADER_VAL

      @data = vals.collect do |data|
        {
          "image_path" => data[0],
          "id"       => data[1],
          "label"    => data[2]
        }
      end
    end 

    protected

    #----------------------------------------------------------------
    def load_variants(path)

      data = JSON.parse File.read(path)
      id = data["@id"]
      w = data["width"]
      h = data["height"]
      thumb_size = data["sizes"].find{|a| a["width"] == config.thumbnail_size || a["height"] == config.thumbnail_size}
      thumb_w = thumb_size["width"]
      thumb_h = thumb_size["height"]
      full_url = "#{id}/full/full/0/default.jpg"
      thumb_url = "#{id}/full/#{thumb_w},/0/default.jpg"
      full = FakeImageVariant.new( id,w, h,full_url, "image/jpeg")
      thumbnail = FakeImageVariant.new( id, thumb_w, thumb_h, thumb_url, "image/jpeg")
      return {"full" => full, "thumbnail" => thumbnail}
    end

    def generate_tiles(data, config) 
      width = data.variants["full"].width
      tile_width = config.tile_width
      height = data.variants["full"].height
      tiles = []
      config.tile_scale_factors.each do |s|
        (0..(height*1.0/(tile_width*s)).floor).each do |tileY|
          (0..(width*1.0/(tile_width*s)).floor).each do |tileX|
            tile = {
              scale_factor: s,
              xpos: tileX,
              ypos: tileY,
              x: tileX * tile_width * s,
              y: tileY * tile_width * s,
              width: tile_width * s,
              height: tile_width * s,
              xSize: tile_width,
              ySize: tile_width
            }
            if (tile[:x] + tile[:width]  > width)
              tile[:width]  = width  - tile[:x]
              tile[:xSize]  = (tile[:width]/(s*1.0)).ceil
            end
            if (tile[:y] + tile[:height] > height)
              tile[:height] = height - tile[:y] 
              tile[:ySize]  = (tile[:height]/(s*1.0)).ceil
            end
            tiles.push(tile)
          end
        end
      end
      tiles.each do |tile|
        ImageTile.new(data, @config, tile)
      end
    end

    def image_info_file_name(data)
      "#{generate_image_location(data.id,data.page_number)}/info.json"
    end

    def generate_image_json(data, config) 
      filename = image_info_file_name(data)
      info = ImageInfo.new(data.variants["full"].id, data.variants ,config.tile_width, config.tile_scale_factors)

      puts "writing #{filename}" if config.verbose?
      Pathname.new(Pathname.new(filename).dirname).mkpath
      File.open(filename, "w") do |file|
       file.puts info.to_json 
      end
      if @config.upload_to_s3
        add_file_to_s3(filename)
        add_default_redirect(filename)
      end
      return info
    end


    def generate_manifest(data, config)
        m = Manifest.new(data, config)
        m.save_all_files_to_disk
        return m
    end

    def build_a_manifest

      manifest_uri = "@config.s3.bucket/#{generate_id(record)}/manifest.json"
      # response = Typhoeus.get(manifest_uri, followlocation: true)
      # if response.code == 200
      #   puts "Skipping #{file}—Manifest already exists." if verbose
      #   data = JSON.parse(response.body)
      #   obj = IiifS3::FakeManifest.new(data["@id"], data["@type"], data["label"])
      #   @iiif.manifests.push(obj)
      #   next
      # end 
    end


    def generate_variants(data, config)
      obj = {
        "full" => FullImage.new(data, config),
        "thumbnail" => Thumbnail.new(data, config)
      }

      config.variants.each do |key,image_size|
        obj[key] = ImageVariant.new(data, config, image_size, image_size)
      end
      return obj
    end
  end
end