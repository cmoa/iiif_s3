require 'spec_helper'

shared_examples "base properties" do
  it "has a description" do
    test_string = "test description"
    @object.description = test_string
    expect(@object.description).to eq test_string
  end
  it "has an @id" do
    expect(@object.id).not_to be_nil
  end
  it "has a valid @id" do
    expect(@object.id).to include IiifS3::Config::DEFAULT_URL
  end
  it "encodes @ids when set" do
    @object.id = "http://www.example.com/a space"
    expect(@object.id).to include "%20"
  end
  it "reveals the type" do
    expect(@object.type).to eq described_class::TYPE
  end
end