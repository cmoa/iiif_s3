module IiifS3
  class Manifest
    include IiifS3


    #--------------------------------------------------------------------------
    # CONSTANTS
    #--------------------------------------------------------------------------

    MANIFEST_TYPE             = "sc:Manifest"
    SEQUENCE_TYPE             = "sc:Sequence"
    CANVAS_TYPE               = "sc:Canvas"
    ANNOTATION_TYPE           = "oa:Annotation"
    IMAGE_TYPE                = "dcterms:Image"
    MOTIVATION                = "sc:painting"
    DEFAULT_CANVAS_LABEL      = "front"
    DEFAULT_VIEWING_DIRECTION = "left-to-right"
    MIN_CANVAS_SIZE           = 1200

    #--------------------------------------------------------------------------
    # CONSTRUCTOR
    #--------------------------------------------------------------------------

    def initialize(data,config)
      primary = data.find{|data| data["is_master"]}
      raise IiifS3::InvalidImageData, "No 'is_master' was found in the image data." unless primary

      @data = Hash.new
      @data["@context"] = PRESENTATION_CONTEXT
      @data["@type"] = MANIFEST_TYPE
      @data["@id"] = "#{config.base_uri}/#{primary['id']}/manifest"
      @data["@id"] += ".json" if config.use_extensions
      @data["label"] = primary["label"] || ""


      # @data["metadata"] = data["metadata"] || {}
      # @data["description"] = data["description"]
      @data["thumbnail"] = primary["variants"]["thumbnail"].uri

      # @data["license"]     = "http://www.example.org/license.html"
      # @data["attribution"] = "Provided by Example Organization"
      # @data["logo"]        = "http://www.example.org/logos/institution1.jpg"

      @data["viewingDirection"] = DEFAULT_VIEWING_DIRECTION
      @data["viewingDirection"] = primary["viewingDirection"] if is_valid_viewing_direction(primary["viewingDirection"]) 
      @data["viewingHint"] = primary["is_document"] ? "paged" : "individuals"

      @data["sequences"] = [build_sequence(data,config)]

      # @data[related] = 
    end


    #--------------------------------------------------------------------------
    def build_sequence(data,config) 
      {
        "@type" => SEQUENCE_TYPE,
        "canvases" => data.collect {|datum| build_canvas(datum,config)}
      } 
    end

    #--------------------------------------------------------------------------
    def build_canvas(data,config)

      canvas_name = data["section"] || DEFAULT_CANVAS_LABEL
      canvas_label = data["section_label"] || DEFAULT_CANVAS_LABEL

      obj = {
        "@type" => CANVAS_TYPE,
        "@id"   => "#{config.base_uri}#{config.prefix}/#{data["id"]}/canvas/#{canvas_name}",
        "label" => canvas_label,
        "width" => data["variants"]["full"].width.floor,
        "height" => data["variants"]["full"].height.floor,
        "thumbnail" => data["variants"]["thumbnail"].uri
      }
      obj["images"] = [build_image(data, config, obj)]

      # handle objects that are less than 1200px on a side by doubling canvas size
      if obj["width"] < MIN_CANVAS_SIZE || obj["height"] < MIN_CANVAS_SIZE
        obj["width"]  *= 2
        obj["height"] *= 2
      end
      return obj
    end

    #--------------------------------------------------------------------------
    def build_image(data, config, canvas)
      {
        "@type" => ANNOTATION_TYPE,
        "motivation" => MOTIVATION,
        "resource" => {
          "@id" => data["variants"]["full"].uri,
          "@type" => IMAGE_TYPE,
          "format" => data["variants"]["full"].mime_type,
          "service" => {
            "@context" => IiifS3::IMAGE_CONTEXT,
            "@id" => data["variants"]["full"].id,
            "profile" => IiifS3::LEVEL_0,
          },
          "width" => data["variants"]["full"].width,
          "height" => data["variants"]["full"].height,
        },
        "on" => canvas["@id"]
      }
    end

    #--------------------------------------------------------------------------
    def to_jsonld
      return JSON.pretty_generate @data
    end

  end
end