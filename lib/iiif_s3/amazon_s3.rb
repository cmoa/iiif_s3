#workergnome-iiif
#

require "aws-sdk"
module IiifS3

  class AmazonS3

    attr_reader :bucket

    def initialize
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

    def add_json(key, filename)
      File.open(filename,'rb') do |source_file|
        bucket.put_object({
          acl: "public-read", # accepts private, public-read, public-read-write, authenticated-read, bucket-owner-read, bucket-owner-full-control
          body: source_file, # file/IO object, or string data
          content_type: "application/json",
          key: key, # required
          # metadata: {
          #   "MetadataKey" => "MetadataValue",
          # },
        })
      end
    end    
    
    def add_image(key, filename)

      File.open(filename,'rb') do |source_file|
        bucket.put_object({
          acl: "public-read", # accepts private, public-read, public-read-write, authenticated-read, bucket-owner-read, bucket-owner-full-control
          body: source_file, # file/IO object, or string data
          content_type: "image/jpeg",
          key: key, # required
          # metadata: {
          #   "MetadataKey" => "MetadataValue",
          # },
        })
      end
    end
  end
end
