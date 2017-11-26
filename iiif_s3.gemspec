# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'iiif_s3/version'

Gem::Specification.new do |spec|
  spec.name          = "iiif_s3"
  spec.version       = IiifS3::VERSION
  spec.authors       = ["David Newbury"]
  spec.email         = ["david.newbury@gmail.com"]
  spec.summary       = "A generator for an IIIF level 0 compatible static server on Amazon S3."
  spec.description   = ""
  spec.homepage      = "https://github.com/cmoa/iiif_s3"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency "simplecov", "~> 0.10"

  spec.add_runtime_dependency 'aws-sdk', '~> 3'
  spec.add_runtime_dependency "mini_magick", ">= 4.8"
end
