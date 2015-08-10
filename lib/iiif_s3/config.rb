module IiifS3
  class Config
    DEFAULT_URL = "http://localhost:8000"
    attr_reader :base_uri, :use_prefixes, :output_dir, :prefix
    def initialize(opts = {})
      @base_uri = opts["base_uri"] || DEFAULT_URL
      @use_prefixes = opts["use_prefixes"] || false
      @output_dir = opts["output_dir"] || "./build"
      @prefix = opts["prefix"] || ""
      if @prefix.length > 0 && @prefix[0] != "/"
        @prefix = "/#{@prefix}" 
      end
    end
  end
end