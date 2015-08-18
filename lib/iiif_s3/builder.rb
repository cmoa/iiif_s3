module IiifS3
  require 'json/ld'


  class Builder
    
    
    HEADER_VAL = 'filename'
    
    #
    # @!attribute [r] data
    #   @return [Array<Hash>] The raw data computed for the given set of images
    attr_reader :data

    #
    # @!attribute [r] manifests
    #   @return [Array<Hash>] The manifest hashes for this configuration
    attr_reader :manifests

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
    # Load data into the IIF builder. 
    # 
    # This will load the data, perform some basic verifications on it, and sort
    # it into proper order.
    #
    # @param [Array<Hash>, Hash] data Either a single imagedata hash or an Array of  imagedata hashes.
    # 
    # @raise [IiifS3::Error::InvalidImageData] if any of the data does 
    #   not pass the validation checks
    # 
    # @return [Void]
    # 
    def load(data)
      data = [data].flatten # handle hashes and arrays of hashes

      # validate
      data.each  do |datum| 
        raise IiifS3::Error::InvalidImageData if datum["id"].nil? || datum["page_number"].nil?
      end

      @data = data.sort_by {|datum| [datum["id"], datum["page_number"]] }
    end


    #
    # Take the loaded data and generate all the files.
    #
    #
    # @return [Void]
    # 
    def process_data
      return nil if @data.nil? # do nothing without data.

      resources = {}
      @data.each do |datum|
        
        datum["variants"] = generate_variants(datum, @config)
        generate_tiles(datum, @config)
        generate_image_json(datum, @config)

        # Save the image info for the manifest
        resources[datum["id"]] ||= []
        resources[datum["id"]].push datum
      end

      # Generate the manifests
      resources.each do |key, val|
        manifests.push generate_manifest(val, @config) 
      end
    end    

    # Creates the required directories for exporting to the file system.
    #
    # @return [Void]
    def create_build_directories
      root_dir =  @config.build_location("")
      Dir.mkdir root_dir unless Dir.exists?(root_dir)
      img_dir = @config.build_image_location("","").split("/")[0...-1].join("/")
      Dir.mkdir img_dir unless Dir.exists?(img_dir)
    end


    #
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

    def generate_tiles(data, config) 
      width = data["variants"]["full"].width
      tile_width = config.tile_width
      height = data["variants"]["full"].height
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

    def generate_image_json(data, config) 
      info = ImageInfo.new(data["variants"]["full"].id, data['variants'] ,config.tile_width, config.tile_scale_factors)

      filename = "#{config.build_image_location(data['id'],data['page_number'])}/info.json"
      puts "writing #{filename}"
      File.open(filename, "w") do |file|
       file.puts info.to_json 
      end
      config.add_default_redirect(filename)
      config.add_file_to_s3(filename)
      return info, filename
    end


    def generate_manifest(data, config)
      m = Manifest.new(data, config)
      m.save_to_disk
      return m
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