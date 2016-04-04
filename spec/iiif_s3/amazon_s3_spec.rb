require 'spec_helper'

describe IiifS3::AmazonS3 do

  context "initialization" do

    after(:each) do
      Dotenv.load
    end

    it "initializes without error" do
      skip("no internet connection") unless ENV["TEST_INTERNET_CONNECTIVITY"]
      expect{IiifS3::AmazonS3.new}.not_to raise_error
    end

    it "fails if it does not find the access key" do
      val = ENV.delete('AWS_ACCESS_KEY_ID')
      expect{IiifS3::AmazonS3.new}.to raise_error IiifS3::Error::BadAmazonCredentials
    end
    it "fails if it does not find the access key" do
      ENV.delete('AWS_SECRET_ACCESS_KEY')
      expect{IiifS3::AmazonS3.new}.to raise_error IiifS3::Error::BadAmazonCredentials
    end
    it "fails if it does not find the correct bucket key" do
      ENV.delete('AWS_REGION')
      expect{IiifS3::AmazonS3.new}.to raise_error IiifS3::Error::BadAmazonCredentials
    end    
    it "fails if it does not find the correct bucket key" do
      ENV.delete('AWS_BUCKET_NAME')
      expect{IiifS3::AmazonS3.new}.to raise_error IiifS3::Error::BadAmazonCredentials
    end
    it "fails if the bucket does not exist" do
      skip("no internet connection") unless ENV["TEST_INTERNET_CONNECTIVITY"]
      cached_val = ENV['AWS_BUCKET_NAME']
      ENV['AWS_BUCKET_NAME'] = 'nonexistent_bucket_name_for_iiif'
      expect{IiifS3::AmazonS3.new}.to raise_error IiifS3::Error::BadAmazonCredentials
      ENV['AWS_BUCKET_NAME'] = cached_val
    end    
  end

  context "Saving data" do

    before(:each) do
      skip("no internet connection") unless ENV["TEST_INTERNET_CONNECTIVITY"]
      @s3 = IiifS3::AmazonS3.new
    end

    it "has a bucket object" do
      expect(@s3.bucket).to exist
    end
  end
end