# require 'spec_helper'

# describe IiifS3::Manifest do
#   let (:data) {
#     JSON.parse '{
#       "id": 1,
#       "label": "This is a test image"
#     }'
#   }
#   let (:config) {IiifS3::Config.new()}
#   let (:m) {IiifS3::Manifest.new(data,config)}
#   let (:output) {JSON.parse(m.to_jsonld)}

#   it "is initialized with an array" do
#     expect(m).to be_a(IiifS3::Manifest)    
#   end

#   it "exports JSON-LD" do
#     expect(m.to_jsonld).not_to be_a(JSON)
#   end

#   it "has a @context" do
#     expect(output["@context"]).to eq(IiifS3::PRESENTATION_CONTEXT)
#   end
#   it "has a @type" do
#     expect(output["@type"]).to eq(IiifS3::Manifest::TYPE)
#   end
#   it "has an @id" do
#     expect(output["@id"]).to eq("#{IiifS3::Config::DEFAULT_URL}/1/manifest")
#   end 
  
#   context "config variables" do
#     let (:config) {IiifS3::Config.new({"use_prefixes" => true})}
#     it "the @id has an extension if configured thusly" do
#       expect(output["@id"]).to eq("#{IiifS3::Config::DEFAULT_URL}/1/manifest.json")
#     end
#   end
#   context "config variables" do
#     let (:config) {IiifS3::Config.new({"base_uri" => "http://www.example.com"})}
#     it "uses non-test uris" do
#       expect(output["@id"]).to eq("http://www.example.com/1/manifest")
#     end
#   end
  
#   it "has a label" do
#     expect(output["label"].length).to be > 0
#   end
#   it "does not have a format" do
#     expect(output["format"]).to be_nil
#   end
#   it "does not have a height" do
#     expect(output["height"]).to be_nil
#   end
#   it "does not have a width" do
#     expect(output["width"]).to be_nil
#   end
#   it "does not have a startCanvas" do
#     expect(output["startCanvas"]).to be_nil
#   end

#   it "accepts valid viewing directions" do 
#     dir = "right-to-left"
#     new_data = data
#     new_data["viewingDirection"] = dir
#     m = IiifS3::Manifest.new(new_data,config)
#     o = JSON.parse(m.to_jsonld)
#     expect(o["viewingDirection"]).to eq(dir)

#   end

#   it "rejects invalid viewing directions" do 
#     dir = "wonky"
#     new_data = data
#     new_data["viewingDirection"] = dir
#     m = IiifS3::Manifest.new(new_data,config)
#     o = JSON.parse(m.to_jsonld)
#     expect(o["viewingDirection"]).to eq IiifS3::Manifest::DEFAULT_VIEWING_DIRECTION

#   end

# end