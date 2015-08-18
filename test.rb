require 'dotenv'

Dotenv.load

require 'rmagick'
require_relative 'lib/iiif_s3'
opts = {}

opts[:image_directory_name] = "img"
opts[:output_dir] = "/Users/david/Documents/opensource/mirador"
opts[:variants] = { "reference" => 600, "access" => 1200}
opts[:upload_to_s3] = true

@data = []
@dir = "./data"
@cleanup_list = []
@image_file_types = [".jpg", ".tif", ".jpeg", ".tiff"]


def split_pdf(file)
  name = File.basename(file, File.extname(file))
  path = "#{@dir}/#{file}"

  im = Magick::ImageList.new(path) do
    self.quality = 80
    self.density = '300'
    self.colorspace = Magick::RGBColorspace
    self.interlace = Magick::NoInterlace
  end

  pages = []
  im.each_with_index do |page, index|
    page_file_name = "./tmp/#{name}_#{index+1}.jpg"
    page.write(page_file_name)
    pages.push(page_file_name)
  end
  pages
end

def add_image(file, is_doc = false)
  name = File.basename(file, File.extname(file))
  name_parts = name.split("_")
  is_paged = name_parts.length == 8
  page_num = is_paged ? name_parts[7].to_i : 1
  name_parts.pop if is_paged
  id = name_parts.join("_")

  obj = {
        "image_path" => "#{file}",
        "id"       => id,
        "label"    => name_parts.join("."),
        "is_master" => page_num == 1,
        "page_number" => page_num,
        "is_document" => false,
        "description" => "This is a test file generated as part of the development on the ruby IiifS3 Gem. <b> This should be bold.</b>"
    }

  if is_paged
    obj["section"] = "p#{page_num}"
    obj["section_label"] = "Page #{page_num}"
  end

  if is_doc
    obj["is_document"] = true
  end
  @data.push obj
end

def add_to_cleanup_list(img)
  @cleanup_list.push(img)
end

def cleanup
  @cleanup_list.each do |file|
    File.delete(file)
  end
end


iiif = IiifS3::Builder.new(opts)
iiif.create_build_directories

Dir.foreach(@dir) do |file|
  if @image_file_types.include? File.extname(file)
    add_image("#{@dir}/#{file}")
  elsif File.extname(file) == ".pdf"
    images = split_pdf(file)
    images.each  do |img| 
      add_image(img, true)
      add_to_cleanup_list(img)
    end
  end    
end

iiif.load(@data)
iiif.process_data
cleanup
