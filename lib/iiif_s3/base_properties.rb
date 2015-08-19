module IiifS3
  module BaseProperties
 

    attr_accessor :label

    attr_reader :id
 
    attr_reader :description

    attr_accessor :metadata
    attr_accessor :attribution
    attr_accessor :logo
    attr_accessor :license
    attr_accessor :related

    def type
      self.class::TYPE
    end

    def id=(_id)
      @id = URI.escape(_id)
      @id += ".json" if @config.use_extensions
    end

    def description=(_desc)
      @description = _desc
    end

    def base_properties
      obj = { 
        "@context" => PRESENTATION_CONTEXT,
        "@id" => self.id,
        "@type" => self.type,
        "label" => self.label
      }
      obj["description"] = self.description if self.description
      obj
    end

    def save
      save_to_disk(JSON.parse(self.to_json))
    end

    protected
    #--------------------------------------------------------------------------
    def save_to_disk(data)
      #data = data.clone
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
