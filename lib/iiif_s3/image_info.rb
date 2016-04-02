module IiifS3

  #
  # Class ImageInfo is a data object for the JSON representation of the image.
  # 
  # It is designed to support the http://iiif.io/api/image/2.0/#image-information spec.
  class ImageInfo

      attr_accessor :id
      attr_accessor :width
      attr_accessor :height
      attr_accessor :tile_width
      attr_accessor :tile_scale_factors

      def initialize(uri, variants, tile_width= nil, tile_scale_factors = nil)

        raise IiifS3::Error::InvalidImageData, "No full variant provided:  variants: #{variants}" unless variants["full"]
        raise IiifS3::Error::InvalidImageData, "No thumbnail variant provided:  variants: #{variants}" unless variants["thumbnail"]
        raise IiifS3::Error::InvalidImageData, "No URI was provided for this image!" if uri.nil?

        @id = uri
        full = variants["full"]
        @variants = variants
        @width = full.width
        @height = full.height
        @tile_width = tile_width
        @tile_scale_factors = tile_scale_factors
      end

      # @return [Hash] a collection of valid sizes based on the available image variants
      #  
      def sizes
         @variants.collect do |name,obj|
          {"width" => obj.width, "height" => obj.height}
        end
      end

      # The hash of tile information, or nil if the information does not exist.
      #
      #
      # @return [Hash, nil] A hash of the tile metadata properly formatted for IIIF JSON.
      # 
      def tiles
        return nil if @tile_scale_factors.nil? || @tile_scale_factors.empty?
        
        return [{
          "width" => @tile_width,
          "scaleFactors" => @tile_scale_factors
        }]
      end


      # Generate the JSON data for this image in the IIIF-expected format.
      #
      #
      # @return [String] the JSON representation of this image
      # 
      def to_json
        obj = {
          "@context" => context,
          "@id" => URI.escape(id),
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

      # @return [String] The IIIF context for this image
      def context
       IiifS3::IMAGE_CONTEXT
      end

      # @return [String] The IIIF protocol for this image
      def protocol 
        IiifS3::IMAGE_PROTOCOL
      end

      # @return [String] The IIIF profile this image supports
      def profile
        [IiifS3::LEVEL_0,{
          supports: ["cors","sizeByWhListed", "baseUriRedirect"]
        }]
      end

      # TODO:  Implement this.  See <http://iiif.io/api/annex/services/#physical-dimensions>
      def service
        return nil
      end
  end
end