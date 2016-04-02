module IiifS3

  #
  # Class Collection is an abstraction over the IIIF Collection, which is an aggregation
  # of IIIF manifests. 
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  class Collection

    # @return [String] The IIIF Type for collections
    TYPE = "sc:Collection"

    include BaseProperties
    attr_reader :collections, :manifests

    def initialize(label, config, name="top")  
      raise IiifS3::Error::MissingCollectionName if label.nil? || label.empty?
      @config = config
      @manifests = []
      @collections = []
      self.label = label
      self.id = "collection/#{name}"
    end

    def add_collection(collection)
      raise IiifS3::Error::NotACollection unless collection.respond_to?(:type) && collection.type == Collection::TYPE
      @collections.push(collection)
    end

    def add_manifest(manifest)
      raise IiifS3::Error::NotAManifest unless manifest.respond_to?(:type) && manifest.type == Manifest::TYPE
      @manifests.push(manifest)
    end

    # The JSON representation of this collection in the IIIF-expected format
    #
    #
    # @return [String] The JSON representation as a string
    # 
    def to_json
      obj = base_properties
      obj["collections"] = collect_object(collections) unless collections.empty?
      obj["manifests"] = collect_object(manifests) unless manifests.empty?
      JSON.pretty_generate obj
    end

    protected

    def collect_object(things)
      things.collect do |thing|
        {
          "@id" => thing.id,
          "@type" => thing.type,
          "label" => thing.label
        }
      end
    end
  end
end

