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

    # This will initialize a new manifest.
    #
    # @param [Array<ImageRecord>] image_records An array of ImageRecord types
    # @param [<type>] config <description>
    # @param [<type>] opts <description>
    # 
    def initialize(image_records,config, opts = {})
      @config = config
      image_records.each do |record|
        raise IiifS3::Error::InvalidImageData, "The data provided to the manifest were not ImageRecords" unless record.is_a? ImageRecord
      end

      @primary = image_records.find{|obj| obj.is_primary}
      raise IiifS3::Error::InvalidImageData, "No 'is_primary' was found in the image data." unless @primary
      raise IiifS3::Error::MultiplePrimaryImages, "Multiple primary images were found in the image data." unless image_records.count{|obj| obj.is_primary} == 1

      self.id =          "#{@primary.id}/manifest"
      self.label =        @primary.label       || opts[:label]                 || ""
      self.description =  @primary.description || opts[:description]
      self.attribution =  @primary.attribution || opts.fetch(:attribution, nil) 
      self.logo =         @primary.logo        || opts.fetch(:logo, nil)

      @sequences = build_sequence(image_records)
    end

    #
    # @return [String]  the JSON-LD representation of the manifest as a string.
    # 
    def to_json
      obj = base_properties

      obj["thumbnail"]   = @primary.variants["thumbnail"].uri
      obj["viewingDirection"] = @primary.viewing_direction 
      obj["viewingHint"] = @primary.is_document ? "paged" : "individuals"
      obj["sequences"] = [@sequences]

      return JSON.pretty_generate obj
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
    def save_all_files_to_disk
      data = JSON.parse(self.to_json)
      save_to_disk(data)
      data["sequences"].each do |sequence|
        save_to_disk(sequence)
        sequence["canvases"].each do |canvas|
          save_to_disk(canvas)
          canvas["images"].each do |annotation|
            save_to_disk(annotation)
          end
        end
      end
      return nil
    end

    protected


    #--------------------------------------------------------------------------
    def build_sequence(image_records,opts = {name: DEFAULT_SEQUENCE_NAME}) 
      name = opts.delete(:name)
      seq_id = generate_id "#{@primary.id}/sequence/#{name}"

      opts.merge({
        "@id" => seq_id,
        "@type" => SEQUENCE_TYPE,
        "canvases" => image_records.collect {|image_record| build_canvas(image_record)}
      })
    end

    #--------------------------------------------------------------------------
    def build_canvas(data)

      canvas_id = generate_id "#{data.id}/canvas/#{data.section}"

      obj = {
        "@type" => CANVAS_TYPE,
        "@id"   => canvas_id,
        "label" => data.section_label,
        "width" => data.variants["full"].width.floor,
        "height" => data.variants["full"].height.floor,
        "thumbnail" => data.variants["thumbnail"].uri
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
      annotation_id =  generate_id "#{data.id}/annotation/#{data.section}"
      {
        "@type" => ANNOTATION_TYPE,
        "@id"   => annotation_id,
        "motivation" => MOTIVATION,
        "resource" => {
          "@id" => data.variants["full"].uri,
          "@type" => IMAGE_TYPE,
          "format" => data.variants["full"].mime_type || "image/jpeg",
          "service" => {
            "@context" => IiifS3::IMAGE_CONTEXT,
            "@id" => data.variants["full"].id,
            "profile" => IiifS3::LEVEL_0,
          },
          "width" => data.variants["full"].width,
          "height" => data.variants["full"].height,
        },
        "on" => canvas["@id"]
      }
    end   
  end
end