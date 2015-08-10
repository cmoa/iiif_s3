module IiifS3

  require 'json/ld'

  module Error
    class BlankCSV < StandardError; end
    class InvalidCSV < StandardError; end
  end

  class Builder

    HEADER_VAL = 'filename'
    attr_reader :data, :manifests


    #
    # Initialize the builder.
    #
    # @param [IiifS3::Config] config an optional configuration object
    # 
    def initialize(config = IiifS3::Config.new)
      @manifests = []
      @config = config
      Dir.mkdir config.output_dir unless Dir.exists? config.output_dir
    end


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
      process_data
    end 

    def process_data
      @data.each do |datum|
        datum["full"] = FullImage.new(datum, @config)
        datum["thumbnail"] = Thumbnail.new(datum, @config)
        reference = ImageVariant.new(datum, @config, 600, 600)
        access = ImageVariant.new(datum, @config, 1200, 1200)
        datum['tile_width'] ||= 512
        datum['tile_scale_factors'] ||= [1,2,4,8]
        tiles = generate_tiles(datum, @config, datum['tile_width'], datum['tile_scale_factors'])
        tiles.each do |tile|
          ImageTile.new(datum, @config, tile)
        end

        generate_image_json(datum, @config, datum["full"], [datum["thumbnail"], reference, access])

        m = Manifest.new(datum,@config)

        File.open("#{@config.output_dir}#{@config.prefix}/#{datum["id"]}/manifest.json", "w") do |file|
           file.puts m.to_jsonld
        end
        manifests.push(m)
      end
    end    

    def generate_tiles(data, config, tile_width = 512, scale_factors = [1,2,4,8]) 
      width = data["full"].width
      height = data["full"].height
      tiles = []
      scale_factors.each do |s|
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
      return tiles
    end

    def generate_image_json(data, config, full, variants) 
      obj = {}
      obj["@context"] = IMAGE_CONTEXT
      obj["@id"] = "#{config.base_uri}#{config.prefix}/#{data["id"]}"
      obj["protocol"] = IMAGE_PROTOCOL
      obj["width"] = full.width
      obj["height"] = full.height
      obj["sizes"] = variants.collect do |size|
        {"width" => size.width, "height" => size.height}
      end

      if data["tile_scale_factors"]
        obj["tiles"] = [{
          "width" => data["tile_width"],
          "scaleFactors" => data["tile_scale_factors"]
        }]
      end

      obj["profile"] = [IiifS3::LEVEL_0]

      File.open("#{config.output_dir}#{config.prefix}/#{data["id"]}/info.json", "w") do |file|
       file.puts JSON.pretty_generate obj
      end
    end
  end
end