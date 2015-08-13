module IiifS3

  #
  # Class ImageInfo is a data object for the JSON representation of the image.
  # 
  # It is designed to support the http://iiif.io/api/image/2.0/#image-information spec.
  class ImageInfo

      attr_accessor :id
      attr_accessor :width
      attr_accessor :height


      def initialize(uri, variants, tile_width= nil, tile_scale_factors = nil)

        raise IiifS3::Error::InvalidImageData unless variants["full"]
        raise IiifS3::Error::InvalidImageData unless variants["thumbnail"]

        @id = uri
        full = variants["full"]
        @variants = variants
        @width = full.width
        @height = full.height
        @tile_width = tile_width
        @tile_scale_factors = tile_scale_factors
      end

      def sizes
         @variants.collect do |name,obj|
          {"width" => obj.width, "height" => obj.height}
        end
      end

      def tiles
        return nil if @tile_scale_factors.nil? || @tile_scale_factors.empty?
        
        return [{
          "width" => @tile_width,
          "scaleFactors" => @tile_scale_factors
        }]
      end


      def to_json
        obj = {
          "@context" => context,
          "@id" => id,
          "protocol" => protocol,
          "width" => width,
          "height" => height,
          "sizes" => sizes,
          "profile" => profile,
        }
        obj["tiles"] = tiles unless tiles.nil?
        obj["profile"]  = profile
        obj["service"] = service unless service.nil?
        JSON.pretty_generate obj
      end

      def context
       IiifS3::IMAGE_CONTEXT
      end

      def protocol 
        IiifS3::IMAGE_PROTOCOL
      end

      def profile
        [IiifS3::LEVEL_0]
      end

      # TODO:  Implement this.  See <http://iiif.io/api/annex/services/#physical-dimensions>
      def service
        return nil
      end
  end
end