require 'spec_helper'


describe IiifS3::Utilities::PdfSplitter do
  context "comparing" do
    it "generates the proper number of files" do
      skip("skipping expensive tests") if ENV["SKIP_EXPENSIVE_TESTS"]
      Dir.mktmpdir do |dir|
        results = IiifS3::Utilities::PdfSplitter.split("./spec/data/test.pdf", output_dir: dir)
        expect(results.count).to eq(3)
        results.each do |file|
          File.delete(file)
        end
      end
    end
  end
end