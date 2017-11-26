module IiifS3
  module Utilities

    # Module Helpers provides helper functions.  Which seems logical.
    # 
    # Note that these functions require an @config object to exist on the
    # mixed-in class.  
    #
    # @author David Newbury <david.newbury@gmail.com>
    #
    module Helpers

      # def self.included(klass)
      #   unless respond_to? :config
      #     raise StandardError, "The helpers have been included in class #{klass}, but #{klass} does not have a @config object."
      #   end
      # end

      # This will generate a valid, escaped URI for an object.
      # 
      # This will prepend the standard path and prefix, and will append .json
      # if enabled.
      #
      # @param [String] path The desired ID string
      # @return [String] The generated URI
      def generate_id(path)
        val =  "#{@config.base_url}#{@config.prefix}/#{path}"
        val += ".json" if @config.use_extensions
        URI.escape(val)
      end

      # Given an id, generate a path on disk for that id, based on the config file
      # 
      # @param [String] id the path to the unique key for the object
      # @return [String] a path within the output dir, with the prefix included
      def generate_build_location(id)
        "#{@config.output_dir}#{@config.prefix}/#{id}"
      end

      # Given an id and a page number, generate a path on disk for an image
      # The path will be based on the config file.
      # 
      # @param [String] id the unique key for the object
      # @param [String] page_number the page for this image.
      # @return [String] a path for the image
      def generate_image_location(id, page_number)
        generate_build_location "#{@config.image_directory_name}/#{id}-#{page_number}"
      end


      def get_data_path(data)
        data['@id'].gsub(@config.base_url,@config.output_dir)
      end

      def save_to_disk(data)
        path = get_data_path(data)
        data["@context"] ||= IiifS3::PRESENTATION_CONTEXT
        puts "writing #{path}" if @config.verbose?
        FileUtils::mkdir_p File.dirname(path)
        File.open(path, "w") do |file|
           file.puts JSON.pretty_generate(data)
        end
        add_file_to_s3(path) if @config.upload_to_s3
      end

      def get_s3_key(filename)
        key = filename.gsub(@config.output_dir,"")
        key = key[1..-1] if key[0] == "/"
      end

      def add_file_to_s3(filename)
        key = get_s3_key(filename)
        if File.extname(filename) == ".json" || File.extname(filename)  == ""
          @config.s3.add_json(key,filename) 
        elsif  File.extname(filename) == ".jpg" 
          @config.s3.add_image(key,filename)
        else
          raise "Cannot identify file type!"
        end
      end

      def add_default_redirect(filename) 
        key = filename.gsub(@config.output_dir,"")
        key = key[1..-1] if key[0] == "/"

        name_key = key.split(".")[0..-2].join(".")

        unless key == name_key
          key = "#{@config.base_url}/#{key}"
          puts "adding redirect from #{name_key} to #{key}" if @config.verbose?
          @config.s3.add_redirect(name_key, key)
        end
      end
    end
  end
end