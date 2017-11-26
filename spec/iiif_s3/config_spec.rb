require 'spec_helper'


describe IiifS3::Config do
  context "comparing" do
    it "shows equal things to be equal" do
      expect(IiifS3::Config.new).to eq(IiifS3::Config.new)
    end
    it "shows different things to be different" do
      opts = {tile_width: 99, upload_to_s3: false}
      opts2 = {tile_width: 100, upload_to_s3: false}
      expect(IiifS3::Config.new opts).not_to eq(IiifS3::Config.new opts2)      
    end
  end
end