require 'rmagick'

module IiifS3
  module Utilities

    #
    # Class PdfSplitter is a utility function designed to convert a PDF into a stack of images.
    #
    # @author David Newbury <david.newbury@gmail.com>
    #
    class PdfSplitter
      # Convert a PDF File into a series of JPEG images, one per-page
      #
      # @param [String] path The path to the PDF file
      # @param [Hash] options The configuration hash
      #
      # @return [Array<String>] The paths to the generated files
      # 
      def self.split(path, options={})

        output_dir = options.fetch(:output_dir, "./tmp")
        verbose = options.fetch(:verbose, false)
        puts "processing #{path}" if verbose
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
        im.destroy!
        GC.start
        pages
      end
    end
  end
end