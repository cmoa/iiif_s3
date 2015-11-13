require 'rmagick'

module IiifS3
  module Utilities

    #
    # Class PdfSplitter is a utility function designed to convert a PDF into a stack of images.
    #
    # @author David Newbury <david.newbury@gmail.com>
    #
    class PdfSplitter
      def self.split(path, output_dir="./tmp")

        name = File.basename(path, File.extname(path))

        im = Magick::ImageList.new(path) do
          self.quality = 80
          self.density = '300'
          self.colorspace = Magick::RGBColorspace
          self.interlace = Magick::NoInterlace
        end

        pages = []
        im.each_with_index do |page, index|
          page_file_name = "#{output_dir}/#{name}_#{index+1}.jpg"
          page.write(page_file_name)
          pages.push(page_file_name)
        end
        pages
      end
    end
  end
end