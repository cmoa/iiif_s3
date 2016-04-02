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

  context "#viewing_direction" do
    it "has a sensible default" do
      expect(image_record.viewing_direction).to eq IiifS3::DEFAULT_VIEWING_DIRECTION
    end

    it "rejects invalid viewing directions on init" do 
      opts = {viewing_direction: "wonky"}
      expect{IiifS3::ImageRecord.new(opts)}.to raise_error(IiifS3::Error::InvalidViewingDirection)
    end

    it "rejects setting invalid viewing directions" do 
      expect{image_record.viewing_direction = "wonky"}.to raise_error(IiifS3::Error::InvalidViewingDirection)
    end
  end

  it "initializes with provided hash values" do
    expect(image_record.id).to eq opts[:id]
  end 
  it "ignores unknown data" do
    opts["junk_data"] = "bozo"
    expect{IiifS3::ImageRecord.new(opts)}.not_to raise_error    
  end 
  context "#is_primary" do
    it "defaults to false" do
      image_record.page_number = 2
      expect(image_record.is_primary).to equal(false)
    end
    it "defaults to true for first pages" do
      image_record.page_number = 1
      expect(image_record.is_primary).to equal(true)
    end
    it "has an alias" do
      image_record.page_number = 1
      expect(image_record.is_primary?).to equal(true)
    end
    it "forces is_primary to boolean" do
      image_record.is_primary = "banana"
      expect(image_record.is_primary).to equal(true)
    end
    it "uses page_number for intellegent defaults" do
      image_record.page_number = 1
      expect(image_record.is_primary).to equal(true)
    end
    it "allows page_number default to be overridded" do
      image_record.page_number = 1
      image_record.is_primary = false
      expect(image_record.is_primary).to equal(false)
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
    it "has_an_alias" do
      expect(image_record.is_document?).to equal(false)
    end
    it "forces is_document to boolean" do
      image_record.is_document = "banana"
      expect(image_record.is_document).to equal(true)
    end
  end
end
