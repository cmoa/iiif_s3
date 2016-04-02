module IiifS3

  # Module BaseProperties provides the set of properties that are shared across
  # all IIIF types.  
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  module BaseProperties
 

    # @!attribute [rw] label
    #   @return [String] The human-readable label for this record
    attr_accessor :label

    # @!attribute [r] id
    #   @return [String] The URI for this record
    attr_reader :id
 
    # @!attribute [rw] description
    #   @return [String] The long-form description of this record
    attr_accessor :description
    # @!attribute [rw] metadata
    #   @return [Hash] A set of key/value pairs describing additional metadata for the object.
    attr_accessor :metadata    
    # @!attribute [rw] attribution
    #   @return [String] a human-readable label, typically used for attribution or credit.
    attr_accessor :attribution
    # @!attribute [rw] logo
    #   @return [String] The URI to an image for the logo of the institution associated with this record.
    attr_accessor :logo
    # @!attribute [rw] license
    #   @return [String] The URI to a resource that describes the license or rights statement associated.
    attr_accessor :license
    # @!attribute [rw] related
    #   @return [String, Array<String>] The URI to related resources.  Can be both a string or an array
    attr_accessor :related

    # The type of resource provided by this record.
    #
    # @return [String] The type of record
    # 
    def type
      self.class::TYPE
    end

    # Set the unique id for this record.  
    # This will automatically append the defined prefixes and suffixes.
    #
    # @param [String] _id The unique portion of this ID
    #
    # @return [string] The URI for this record
    # 
    def id=(_id)
      @id = generate_id(_id)
    end

    # Return the base data structure for this record as a Hash
    # This will be in IIIF format, and should convert to JSON as JSON-LD nicely.
    #
    # @return [Hash] The base properties of this record
    # 
    def base_properties
      obj = { 
        "@context" => PRESENTATION_CONTEXT,
        "@id" => self.id,
        "@type" => self.type,
        "label" => self.label
      }
      obj["attribution"] = self.attribution if self.attribution
      obj["logo"] = self.logo if self.logo
      obj["description"] = self.description if self.description
      obj["attribution"] = self.attribution if self.attribution
      obj["license"] = self.license if self.license
      obj["related"] = self.related if self.related

      obj
    end


    # Save the JSON representation of this record to disk and to S3 (if enabled).
    #
    # @return [Void]
    # 
    def save
      save_to_disk(JSON.parse(self.to_json))
    end


    # This will generate a valid, escaped URI for an object.
    # 
    # This will prepend the standard path and prefix, and will append .json
    # if enabled.
    #
    # @param [String] path The desired ID string
    #
    # @return [String] The generated URI
    # 
    def generate_id(path)
      val =  "#{@config.base_uri}#{@config.prefix}/#{path}"
      val += ".json" if @config.use_extensions
      URI.escape(val)
    end

    protected
    #--------------------------------------------------------------------------
    def save_to_disk(data)
      path = data['@id'].gsub(@config.base_uri,@config.output_dir)
      path_parts = path.split("/")
      path_parts.pop
      dir = path_parts.join("/")
      data["@context"] ||= IiifS3::PRESENTATION_CONTEXT
      puts "making dir: #{dir}"
      FileUtils::mkdir_p dir unless Dir.exists? dir
      puts "writing #{path}"
      File.open(path, "w") do |file|
         file.puts JSON.pretty_generate(data)
      end
      @config.add_file_to_s3(path)
    end

  end
end
