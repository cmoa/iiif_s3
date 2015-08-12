require 'spec_helper'

describe IiifS3::ImageVariant do
  let(:config) {IiifS3::Config.new}
  let(:data) { {
      "img_path" => "./spec/data/test.jpg",
      "id" => 1,
      "page_number" => 1
    } }
 
  context "initialization errors" do
    it "raises if the image does not have an ID" do
      data.delete "id"
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end
    it "raises if the image has a blank ID" do
      data["id"] = ""
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end

    it "raises if the image does not have an page number" do
      data.delete "page_number"
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end
    it "raises if the image has a blank page number" do
      data["page_number"] = ""
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end

    it "raises if the image has an invalid path" do
      data["img_path"] = "/i/am/not/a/real/path.jpg"
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end
    it "raises if the image is not a valid image file" do
      data["img_path"] = "./spec/data/test.csv"
      expect{IiifS3::ImageVariant.new(data, config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end

  end

  context "basic data" do
    before(:all) do
      data = {
        "img_path" => "./spec/data/test.jpg",
        "id" => 1,
        "page_number" => 1
      }
       config = IiifS3::Config.new
       @img = IiifS3::ImageVariant.new(data, config, 100, 100)
    end
    
    it "has a uri" do
      expect(@img.uri).to eq("#{config.image_uri(1,1)}/full/83,/0/default.jpg")
    end     
    it "has an id" do
      expect(@img.id).to eq("#{config.image_uri(1,1)}")
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
end