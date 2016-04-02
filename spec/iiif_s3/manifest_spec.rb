 require 'spec_helper'
 require "base_properties_spec"


describe IiifS3::Manifest do
  include_context("fake data")

  context "base" do
      before(:each) do
        @object = m
      end
      it_behaves_like "base properties"
  end

  let (:config) {IiifS3::Config.new()}
  let (:m) {IiifS3::Manifest.new([@fake_data],config)}
  let (:output) {JSON.parse(m.to_json)}

  it "initializes without an error" do
    expect(m).to be_a(IiifS3::Manifest)    
  end


  it "exports JSON-LD as a valid JSON string" do
    expect(m.to_json).to be_a(String)
    expect{JSON.parse(m.to_json)}.not_to raise_error
  end

  it "has a @context" do
    expect(output["@context"]).to eq(IiifS3::PRESENTATION_CONTEXT)
  end
  it "has a @type" do
    expect(output["@type"]).to eq(IiifS3::Manifest::TYPE)
  end
  it "has an @id" do
    expect(output["@id"]).to eq("#{IiifS3::Config::DEFAULT_URL}/1/manifest.json")
  end 
  
  context "error checking" do
    it "throws an error if not provided ImageRecords" do
      expect{IiifS3::Manifest.new(["not an image record"],config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end
    it "throws an error unless there's a primary image" do
      data = @fake_data.clone
      data.is_primary = false
      expect{IiifS3::Manifest.new([data],config)}.to raise_error(IiifS3::Error::InvalidImageData)
    end
    it "throws an error if there are two primary images" do
      data1 = IiifS3::ImageRecord.new({is_primary: true})
      data2 = IiifS3::ImageRecord.new({is_primary: true})

      expect{IiifS3::Manifest.new([data1, data2],config)}.to raise_error(IiifS3::Error::MultiplePrimaryImages)
    end
  end

  context "config variables" do
    let (:config) {IiifS3::Config.new({:use_extensions => false})}
    it "the @id has an extension if configured thusly" do
      expect(output["@id"]).to eq("#{IiifS3::Config::DEFAULT_URL}/1/manifest")
    end
  end

  context "base_url config variable" do
    let (:config) {IiifS3::Config.new({base_url: "http://www.example.com"})}
    it "uses non-test uris" do
      expect(output["@id"]).to eq("http://www.example.com/1/manifest.json")
    end
  end
  
  context "spec requirements" do
    it "has a label" do
      expect(output["label"].length).to be > 0
    end
    it "does not have a format" do
      expect(output["format"]).to be_nil
    end
    it "does not have a height" do
      expect(output["height"]).to be_nil
    end
    it "does not have a width" do
      expect(output["width"]).to be_nil
    end
    it "does not have a startCanvas" do
      expect(output["startCanvas"]).to be_nil
    end
    it "accepts valid viewing directions" do 
      dir = "right-to-left"
      new_data = @fake_data
      new_data.viewing_direction = dir
      m = IiifS3::Manifest.new([new_data],config)
      o = JSON.parse(m.to_json)
      expect(o["viewingDirection"]).to eq(dir)

    end
  end

end