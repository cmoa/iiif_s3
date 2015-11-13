 require 'spec_helper'
 require "base_properties_spec"


describe IiifS3::ImageRecord do
  let(:opts) {{
      id: 1
    }}
    let(:image_record) {IiifS3::ImageRecord.new(opts)}

  it "initializes without an error" do
    expect{IiifS3::ImageRecord.new}.not_to raise_error    
  end
  it "initializes without an error when provided a hash" do
    opts = {id: 1}
    expect{IiifS3::ImageRecord.new(opts)}.not_to raise_error    
  end
  it "initializes with provided hash values" do
    expect(image_record.id).to eq opts[:id]
  end 
  it "ignores unknown data" do
    opts["junk_data"] = "bozo"
    expect{IiifS3::ImageRecord.new(opts)}.not_to raise_error    
  end 
  context "#is_master" do
    it "defaults to false" do
      image_record.page_number = 2
      expect(image_record.is_master).to equal(false)
    end
    it "defaults to true for first pages" do
      image_record.page_number = 1
      expect(image_record.is_master).to equal(true)
    end
    it "forces is_master to boolean" do
      image_record.is_master = "banana"
      expect(image_record.is_master).to equal(true)
    end
    it "uses page_number for intellegent defaults" do
      image_record.page_number = 1
      expect(image_record.is_master).to equal(true)
    end
    it "allows page_number default to be overridded" do
      image_record.page_number = 1
      image_record.is_master = false
      expect(image_record.is_master).to equal(false)
    end
  end
  context "#image_path" do
    it "raises on a blan path" do
      expect{image_record.path = nil}.to raise_error(IiifS3::Error::InvalidImageData)
    end
    it "raises an error for a bad file name" do
      expect{image_record.path = "imaginary_file.jpg"}.to raise_error(IiifS3::Error::InvalidImageData)
    end
  end
  context "#section" do
    it "uses the default for the name" do
      expect(image_record.section).to eq DEFAULT_CANVAS_LABEL
    end
    it "uses the default for the label" do
      expect(image_record.section_label).to eq DEFAULT_CANVAS_LABEL
    end
  end
  context "#is_document" do
    it "defaults to false" do
      expect(image_record.is_document).to equal(false)
    end
    it "forces is_document to boolean" do
      image_record.is_document = "banana"
      expect(image_record.is_document).to equal(true)
    end
  end
end
