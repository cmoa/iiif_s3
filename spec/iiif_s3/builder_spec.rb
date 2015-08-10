require 'spec_helper'

describe IiifS3::Builder do
  let (:iiif) { IiifS3::Builder.new }

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

  context "When reading the data" do
    it "saves the data into the @data param" do
      expect(iiif.data).to be_nil
      iiif.load_csv('./spec/data/test.csv')
      expect(iiif.data).not_to be_nil
    end
    it "removes headers" do
      iiif.load_csv('./spec/data/test.csv')
      expect(iiif.data[0]['img_path']).to eq('spec/data/test.jpg')        
    end
    it "doesn't remove headers if not present" do
      iiif.load_csv('./spec/data/no_header.csv')
      expect(iiif.data[0]['img_path']).to eq('spec/data/test.jpg')        
    end
  end
end
