require_relative 'lib/iiif_s3'

iiif = IiifS3::Builder.new
iiif.load_csv('./spec/data/test.csv')


#puts JSON.pretty_generate iiif.manifests.collect {|i| i.to_jsonld}