RSpec.shared_context "fake variants" do
  before(:example) do
    @fake_variants = {
      "full" => OpenStruct.new(:width => 1000, :height => 1200),
      "thumbnail" => OpenStruct.new(:width => 100, :height => 120)
    }
  end
end