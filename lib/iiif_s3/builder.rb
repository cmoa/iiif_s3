module IiifS3
  require 'json/ld'


  class Builder
    HEADER_VAL = 'filename'
    attr_reader :data, :manifests, :config


    #
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

      data.each {|datum| raise IiifS3::Error::InvalidImageData if datum["id"].nil? || datum["page_number"].nil? }

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
        
        #Generate required variants
        datum["full"] = FullImage.new(datum, @config)
        datum["thumbnail"] = Thumbnail.new(datum, @config)

        # Generate other variants
        reference = ImageVariant.new(datum, @config, 600, 600)
        access = ImageVariant.new(datum, @config, 1200, 1200)

        variants = [datum["thumbnail"], reference, access, datum["full"]]

        # Generate Tiles
        tiles = generate_tiles(datum, @config)
 
        # Generate info.json
        generate_image_json(datum, @config, variants)

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

    def generate_tiles(data, config) 
      width = data["full"].width
      tile_width = config.tile_width
      height = data["full"].height
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

    def generate_image_json(data, config, variants) 
      info = ImageInfo.new(data["full"].id, variants ,config.tile_width, config.tile_scale_factors)

      filename = "#{config.build_image_location(data['id'],data['page_number'])}/info.json"
      puts "writing #{filename}"
      File.open(filename, "w") do |file|
       file.puts info.to_json 
      end
      return info
    end


    def generate_manifest(data, config)
      m = Manifest.new(data, config)
      path = config.build_location(data.first["id"])
      FileUtils::mkdir_p path unless Dir.exists? path

      filename = "#{path}/manifest.json"
      puts "writing #{filename}"

      File.open(filename, "w") do |file|
         file.puts m.to_jsonld
      end
      return m
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
          "img_path" => data[0],
          "id"       => data[1],
          "label"    => data[2]
        }
      end
    end 
  end
end