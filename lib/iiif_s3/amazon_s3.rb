require "aws-sdk"
module IiifS3

  #
  # Class AmazonS3 wraps the functionality needed up upload files to Amazon S3.
  #
  # @author David Newbury <david.newbury@gmail.com>
  #
  class AmazonS3

    attr_reader :bucket

    #
    # Intitializing an AmazonS3 instance will verify that the required
    # ENV keys exist (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_BUCKET_NAME, 
    # and AWS_REGION), verify that the bucket exists, and then connect to
    # that bucket.
    # 
    # It will also set the CORS rules to allow cross-domain access to that bucket, as well
    # as configuring the bucket as a website.
    #
    # @return [Void]
    # 
    def initialize(options = {})
      defaults = {
        verbose: false
      }
      @options = defaults.merge(options)
      if ENV['AWS_ACCESS_KEY_ID'].nil?
        raise IiifS3::Error::BadAmazonCredentials, "Could not find the correct Access Key ID in ENV['AWS_ACCESS_KEY_ID']"
      elsif ENV['AWS_SECRET_ACCESS_KEY'].nil?
        raise IiifS3::Error::BadAmazonCredentials, "Could not find the correct secret in ENV['AWS_SECRET_ACCESS_KEY']"
      elsif ENV['AWS_BUCKET_NAME'].nil?
        raise IiifS3::Error::BadAmazonCredentials, "Could not find a bucket name in ENV['AWS_BUCKET_NAME']"
      elsif ENV['AWS_REGION'].nil?
        raise IiifS3::Error::BadAmazonCredentials, "Could not find a AWS region in ENV['AWS_REGION']"
      end

      @bucket = Aws::S3::Bucket.new(ENV['AWS_BUCKET_NAME'])
      unless @bucket.exists?
        raise IiifS3::Error::BadAmazonCredentials, "The bucket name in ENV['AWS_BUCKET_NAME'] does not exist.  You supplied '#{ENV['AWS_BUCKET_NAME']}'" 
      end
      @bucket.cors.put(cors_rules)
      @bucket.website.put(website_rules)
      return nil
    end

    #
    # Upload a file to the default bucket.  By default, this will upload a file
    # with public-read permissions, and any standard metadata.  passing in an
    # options hash as the last parameter allows one to add or overwrite any of 
    # the default parameters.
    #
    # @param [String] key The ID that the file will be uploaded to.
    #   Typically, this is the path of the URI, without the domain or port.
    # @param [String] filename The path on the local file system to the
    #   file that should be uploaded
    # @param [Hash] options Any values that should be uploaded to override or
    # append to the default parameters.
    #
    # @return [Hash] The completed options hash.
    # 
    def upload_file(key, filename, options = {})
      obj = {
          acl: "public-read",
          key: key
          # metadata: {
          #   "MetadataKey" => "MetadataValue",
          # },
      }
      obj.merge!(options)

      puts "uploading #{filename} to #{key}" if @options[:verbose]
      File.open(filename,'rb') do |source_file|
        obj[:body] = source_file
        bucket.put_object(obj)
      end
      return obj
    end

    #
    # A helper method for uploading a JSON file to S3.
    #
    # @param [String] key The ID that the file will be uploaded to.
    #   Typically, this is the path of the URI, without the domain or port.
    # @param [String] filename The path to a JSON file on the local file 
    #  system that should be uploaded.
    #
    # @return [Hash] The completed options hash.
    # 
    def add_json(key, filename)
      obj = {content_type: "application/json"}
      upload_file(key, filename, obj)
    end    
    

    #
    # A helper method for uploading a JPEG file to S3.
    #
    # @param [String] key The ID that the file will be uploaded to.
    #   Typically, this is the path of the URI, without the domain or port.
    # @param [String] filename The path to a JPEG file on the local file 
    #  system that should be uploaded.
    #
    # @return [Hash] The completed options hash.
    # 
    def add_image(key, filename)
      obj = {content_type:  "image/jpeg"}
      upload_file(key, filename, obj)
    end

    def add_redirect(key, redirect_key) 
       obj = {
          acl: "public-read",
          key: key,
          website_redirect_location: redirect_key
        }
      bucket.put_object(obj)
    end

    protected

    def website_rules
      {
        website_configuration: { # required
          error_document: {
            key: "error.html", # required
          },
          index_document: {
            suffix: "index.html", # required
          }
        }
      }
    end
    
    def cors_rules
      {
        cors_configuration: {
          cors_rules: [
            {
              allowed_methods: ["GET"],
              allowed_origins: ["*"],
              allowed_headers: ["*"],
              expose_headers: ["access-control-allow-origin"]
            }
          ]
        }
      }
    end

  end
end
