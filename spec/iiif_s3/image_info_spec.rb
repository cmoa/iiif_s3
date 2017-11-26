require 'spec_helper'
require 'ostruct'

include IiifS3

describe IiifS3::ImageInfo do

  let(:uri) {"http://www.example.com/test/1"}
  include_context("fake variants")

  context "intialization" do

  
    it "initializes without errors" do  
      expect{ImageInfo.new(uri,@fake_variants)}.not_to raise_error
    end
    it "raises an error without a 'full' variant" do
      @fake_variants.delete "full"
      expect{ImageInfo.new(uri,@fake_variants)}.to raise_error(Error::InvalidImageData)
    end
    it "raises an error without a 'thumbnail' variant" do
      @fake_variants.delete "thumbnail"
      expect{ImageInfo.new(uri,@fake_variants)}.to raise_error(Error::InvalidImageData)
    end
  end


  context "valid data" do
    before(:example) do 
      @info = ImageInfo.new(uri,@fake_variants)
    end  

    it "generates correct sizes" do
      expect(@info.sizes).to eq([{"width" => 1000, "height" => 1200},{"width" => 100, "height" => 120}])
    end

    it "generates nil when no tile data appears" do
      expect(@info.tiles).to be_nil
    end

    it "generates tile info when tile data appears" do
      info = ImageInfo.new(uri,@fake_variants,500,[1,2,4])
      expect(info.tiles).to eq([{"width" => 500, "scaleFactors" => [1,2,4]}])
    end

    it "has the correct other methods" do
      expect(@info).to respond_to "context"
      expect(@info).to respond_to "protocol"
      expect(@info).to respond_to "profile"
      expect(@info).to respond_to "service"
    end

    it "generates correct JSON" do
      expect(@info.to_json).to eq(@fake_image_info)
    end
  end
end