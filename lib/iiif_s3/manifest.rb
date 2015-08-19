module IiifS3


  #
  # Class Manifest is an abstraction over the IIIF Manifest, and by extension over the
  # entire Presentation API.  It takes the internal representation of data and converts
  # it into a collection of JSON-LD documents.  Optionally, it also provides the ability
  # to save these files to disk and upload them to Amazon S3.
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  class Manifest

    # @return [String] The IIIF default type for a manifest.
    TYPE = "sc:Manifest"

    include BaseProperties

    #--------------------------------------------------------------------------
    # CONSTRUCTOR
    #--------------------------------------------------------------------------

    def initialize(data,config)
      @config = config
      @primary = data.find{|data| data["is_master"]}
      raise IiifS3::InvalidImageData, "No 'is_master' was found in the image data." unless @primary


      self.id = "#{config.base_uri}/#{@primary['id']}/manifest"
      self.label = @primary["label"] || ""
      self.description = @primary["description"]
      @data = base_properties

      @data["thumbnail"]   = @primary["variants"]["thumbnail"].uri

      # @data["metadata"] = data["metadata"] || {}
      # @data["license"]     = "http://www.example.org/license.html"
      # @data["attribution"] = "Provided by Example Organization"
      # @data["logo"]        = "http://www.example.org/logos/institution1.jpg"

      @data["viewingDirection"] = DEFAULT_VIEWING_DIRECTION
      @data["viewingDirection"] = @primary["viewingDirection"] if IiifS3.is_valid_viewing_direction(@primary["viewingDirection"]) 
      @data["viewingHint"] = @primary["is_document"] ? "paged" : "individuals"

      @data["sequences"] = [build_sequence(data)]

      # @data[related] = 
    end

    #
    #
    # @return [String]  the JSON-LD representation of the manifest as a string.
    # 
    def to_json
      return JSON.pretty_generate @data
    end

    #
    # Save the manifest and all sub-resources to disk, using the
    # paths contained withing the IiifS3::Config object passed at 
    # initialization.
    # 
    # Will create the manifest, sequences, canvases, and annotation subobjects.
    #
    # @return [Void] 
    # 
    def save_to_disk
      data = @data
      save_subfile(@data)
      @data["sequences"].each do |sequence|
        save_subfile(sequence)
        sequence["canvases"].each do |canvas|
          save_subfile(canvas)
          canvas["images"].each do |annotation|
            save_subfile(annotation)
          end
        end
      end
      return nil
    end

    protected


    #--------------------------------------------------------------------------
    def build_sequence(data,opts = {name: DEFAULT_SEQUENCE_NAME}) 
      name = opts.delete(:name)
      id = "#{@config.base_uri}/#{@primary['id']}/sequence/#{name}"
      id += ".json" if @config.use_extensions

      opts.merge({
        "@id" => URI.escape(id),
        "@type" => SEQUENCE_TYPE,
        "canvases" => data.collect {|datum| build_canvas(datum)}
      })
    end

    #--------------------------------------------------------------------------
    def build_canvas(data)

      canvas_name = data["section"] || DEFAULT_CANVAS_LABEL
      canvas_label = data["section_label"] || DEFAULT_CANVAS_LABEL

      id = "#{@config.base_uri}#{@config.prefix}/#{data["id"]}/canvas/#{canvas_name}"
      id += ".json" if @config.use_extensions

      obj = {
        "@type" => CANVAS_TYPE,
        "@id"   => URI.escape(id),
        "label" => canvas_label,
        "width" => data["variants"]["full"].width.floor,
        "height" => data["variants"]["full"].height.floor,
        "thumbnail" => data["variants"]["thumbnail"].uri
      }
      obj["images"] = [build_image(data, obj)]

      # handle objects that are less than 1200px on a side by doubling canvas size
      if obj["width"] < MIN_CANVAS_SIZE || obj["height"] < MIN_CANVAS_SIZE
        obj["width"]  *= 2
        obj["height"] *= 2
      end
      return obj
    end

    #--------------------------------------------------------------------------
    def build_image(data, canvas)
      name = canvas['@id'].split("/").last
      id =  "#{@config.base_uri}#{@config.prefix}/#{data["id"]}/annotation/#{name}"
      {
        "@type" => ANNOTATION_TYPE,
        "@id"   => URI.escape(id),
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

    
  end
end