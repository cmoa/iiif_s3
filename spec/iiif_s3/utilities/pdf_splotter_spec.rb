require 'spec_helper'


describe IiifS3::Utilities::PdfSplitter do
  context "comparing" do
    it "generates the proper number of files" do
      skip("skipping expensive tests") if $SKIP_EXPENSIVE_TESTS
      results = IiifS3::Utilities::PdfSplitter.split("./spec/data/test.pdf")
      expect(results.count).to eq(3)
    end
  end
end