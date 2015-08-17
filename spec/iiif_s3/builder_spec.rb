require 'spec_helper'
require 'ostruct'

describe IiifS3::Builder do
  # before(:each) do
  #   fake_aws_bucket = OpenStruct.new({
  #     "exists?" => "true"
  #   })
  #   unless $INTERNET
  #     allow(Aws::S3::Bucket).to receive(:new) {nil}
  #     allow(Aws::S3::Bucket).to receive(:exists?) {true}
  #   end
  # end

  let (:iiif) { IiifS3::Builder.new() }
  let (:test_object_0) {{"id" => 1, "page_number" => 1}}
  let (:test_object_1) {{"id" => 2, "page_number" => 1}}
  let (:test_object_2) {{"id" => 2, "page_number" => 2}}
  let (:data) {[test_object_0, test_object_1,test_object_2]}

  context "When initializing" do
    it "generates manifests" do
      expect(iiif.manifests).to eq(Array.new)
    end
    it "uses the default config" do
      expect(iiif.config).to eq(IiifS3::Config.new)
    end
    it "will accept a configuration hash" do
      opts = {tile_width: 99}
      iiif2 = IiifS3::Builder.new(opts)
      expect(iiif2.config.tile_width).to eq(99)
    end
  end

  context "loading data" do
    it "will accept an array of objects" do
      iiif.load(data)
      expect(iiif.data).to eq(data)
    end 
    it "will accept a single object" do 
      iiif.load(test_object_1)
      expect(iiif.data).to eq([test_object_1])
    end
    it "will sort objects into ID and page order " do 
      iiif.load([test_object_2,test_object_0,test_object_1])
      expect(iiif.data).to eq(data)
    end

    it "will error if the data is bad" do
      expect{iiif.load({random: "hash"})}.to raise_error(IiifS3::Error::InvalidImageData)
      expect{iiif.load([{random: "hash"}])}.to raise_error(IiifS3::Error::InvalidImageData)
    end
  end

  context " when processing data" do
    include_context("fake variants")
    include_context("fake data")
    before(:example) do
      @iiif = IiifS3::Builder.new({base_uri: 'http://localhost:8000'})
      @iiif.load(@fake_data)
      allow(@iiif).to receive(:generate_tiles) {nil}
      allow(@iiif).to receive(:generate_variants) {@fake_variants}

    end
    it "does not fail with no data" do
      expect {iiif.process_data}.not_to raise_error
    end

    it "does not fail with real data" do
      expect {@iiif.process_data}.not_to raise_error
    end
  
    it " passes the Temporary Manifest Check" do
      @iiif.process_data
      expect(@iiif.manifests.count).to eq 1
      expect(@iiif.manifests[0][0].to_jsonld).to eq @fake_manifest
    end
  end


  context "When load_csving CSV files" do
    it "accepts a path" do
      expect{iiif.load_csv('./spec/data/test.csv')}.not_to raise_error()
    end
    it "fails on blank CSV files" do
      expect{iiif.load_csv('./spec/data/blank.csv')}.to raise_error(IiifS3::Error::BlankCSV)
    end
    it "fails on invalid CSV files" do
      expect{iiif.load_csv('./spec/data/invalid.csv')}.to raise_error(IiifS3::Error::InvalidCSV)
    end
    it "fails on missing CSV files" do
      expect{iiif.load_csv('./spec/data/i_dont_exist.csv')}.to raise_error(IiifS3::Error::InvalidCSV)
    end
  end

  context "When loading a CSV file" do
    it "saves the data into the @data param" do
      expect(iiif.data).to be_nil
      iiif.load_csv('./spec/data/test.csv')
      expect(iiif.data).not_to be_nil
    end
    it "removes headers" do
      iiif.load_csv('./spec/data/test.csv')
      expect(iiif.data[0]['image_path']).to eq('spec/data/test.jpg')        
    end
    it "doesn't remove headers if not present" do
      iiif.load_csv('./spec/data/no_header.csv')
      expect(iiif.data[0]['image_path']).to eq('spec/data/test.jpg')        
    end
  end
end
