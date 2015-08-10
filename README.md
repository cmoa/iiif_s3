# IiifS3

This tool is designed to be used to generate IIIF compatible images stacks and metatdata from a collection of images, and then to upload those images to Amazon S3 for static serving.

It accepts a CSV file of records.  Those CSV files should be in the following format:

filename          | identifier
------------------|------------
./images/test.png | 111222333

The headers are optional, but recommended.



Standard use of the tool is:

iiif_s3 publish <file.csv>


## Installation

This library assumes that you have ImageMagick installed.  If you need to install it, follow the instructions:

on OSX, `brew install imagemagick` should be sufficient.



Add this line to your application's Gemfile:

    gem 'iiif_s3'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iiif_s3

## Usage

IiifS3 assumes that you have an Amazon S3 account configured for use.  By default, it uses the same locations that the Amazon S3 ruby library searches:

> 
  ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']
  The shared credentials ini file at ~/.aws/credentials (more information)
  From an instance profile when running on EC2

  The SDK also searches the following locations for a region:
  ENV['AWS_REGION']



## Contributing

1. Fork it ( https://github.com/cmoa/iiif_s3/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
