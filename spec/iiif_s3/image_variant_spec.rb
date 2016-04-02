require 'spec_helper'

describe IiifS3::ImageVariant do
  let(:config) {IiifS3::Config.new}
  let(:data) { IiifS3::ImageRecord.new({
      "path" => "./spec/data/test.jpg",
      "id" => 1,
      "page_number" => 1
    }) }
 
  context "initialization errors" do
    it "raises if the image does not have an ID" do
      data.id =nil
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end
    it "raises if the image has a blank ID" do
      data.id = ""
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end

    it "raises if the image is not a valid image file" do
      data.path = "./spec/data/test.csv"
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end

  end

  context "basic data" do
    before(:all) do
      data = IiifS3::ImageRecord.new({
        "path" => "./spec/data/test.jpg",
        "id" => 1,
        "page_number" => 1
      })
       config = IiifS3::Config.new
       @img = IiifS3::ImageVariant.new(data, config, 100, 100)
    end
    
    it "has a uri" do
      expect(@img.uri).to eq("#{@img.generate_image_id(1,1)}/full/83,/0/default.jpg")
    end     
    it "has an id" do
      expect(@img.id).to eq("#{@img.generate_image_id(1,1)}")
    end 
    it "has a width" do
      expect(@img.width).to eq(83)
    end    
    it "has a height" do
      expect(@img.height).to eq(100)
    end 
    it "has a mime type" do
      expect(@img.mime_type).to eq("image/jpeg")   
    end
  end

  context "Full Image" do
    before(:all) do
      data = IiifS3::ImageRecord.new({
        "path" => "./spec/data/test.jpg",
        "id" => 1,
        "page_number" => 1
      })
       config = IiifS3::Config.new
       @img = IiifS3::FullImage.new(data, config)
    end
    it "has the default filestring" do
      expect(@img.uri).to include "full/full"
    end

  end
end