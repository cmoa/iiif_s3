$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "shared_contexts"
require 'iiif_s3'
require 'dotenv'

Dotenv.load