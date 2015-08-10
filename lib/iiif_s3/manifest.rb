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
      @data = Hash.new
      @data["@context"] = PRESENTATION_CONTEXT
      @data["@type"] = MANIFEST_TYPE
      @data["@id"] = "#{config.base_uri}/#{data['id']}/manifest"
      @data["@id"] += ".json" if config.use_prefixes
      @data["label"] = data["label"] || ""


      # @data["metadata"] = data["metadata"] || {}
      # @data["description"] = data["description"]
      @data["thumbnail"] = data["thumbnail"].uri

      # @data["license"]     = "http://www.example.org/license.html"
      # @data["attribution"] = "Provided by Example Organization"
      # @data["logo"]        = "http://www.example.org/logos/institution1.jpg"

      @data["viewingDirection"] = DEFAULT_VIEWING_DIRECTION
      @data["viewingDirection"] = data["viewingDirection"] if is_valid_viewing_direction(data["viewingDirection"]) 

      @data["sequences"] = [build_sequence(data,config)]
      # @data[viewingHint] = "individuals"

      # @data[related] = 
    end


    #--------------------------------------------------------------------------
    def build_sequence(data,config) 
      {
        "@type" => SEQUENCE_TYPE,
        "canvases" => [build_canvas(data,config)]
      } 
    end

    #--------------------------------------------------------------------------
    def build_canvas(data,config)
      puts data["full"].width
      obj = {
        "@type" => CANVAS_TYPE,
        "@id"   => "#{config.base_uri}#{config.prefix}/#{data["id"]}/canvas/#{DEFAULT_CANVAS_LABEL}",
        "label" => DEFAULT_CANVAS_LABEL,
        "width" => data["full"].width.floor,
        "height" => data["full"].height.floor,
        "thumbnail" => data["thumbnail"].uri
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
          "@id" => data["full"].uri,
          "@type" => IMAGE_TYPE,
          "format" => data["full"].mime_type,
          "service" => {
            "@context" => IiifS3::IMAGE_CONTEXT,
            "@id" => "#{config.base_uri}#{data["full"].base_path}",
            "profile" => IiifS3::LEVEL_0,
          },
          "width" => data["full"].width,
          "height" => data["full"].height,
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