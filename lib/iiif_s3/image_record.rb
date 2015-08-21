module IiifS3
  class ImageRecord
    attr_accessor :id
    attr_accessor :label
    attr_accessor :is_document
    attr_accessor :description
    
    attr_writer :path
    attr_writer :page_number
    attr_writer :section
    attr_writer :section_label
    attr_writer :is_document
    attr_accessor :viewing_direction
    attr_accessor :variants
    
    def initialize(opts={})
      opts.each do |key, val|
        self.send("#{key}=",val) if self.methods.include? "#{key}=".to_sym
      end
    end

    def page_number
      @page_number || 1
    end

    def path=(_path)
      raise IiifS3::Error::InvalidImageData unless File.exist? _path
      @image_path = _path
    end

    def is_document
      return !!@is_document
    end

    def section
      @section || DEFAULT_CANVAS_LABEL
    end

    def section_label
      @section || DEFAULT_CANVAS_LABEL
    end

    def is_master
      if @is_master.nil?
        self.page_number == 1
      else
        @is_master
      end
    end

    def is_master=(val)
      @is_master = !!val
    end
  end
end


 # obj = {
 #        "image_path" => "#{file}",
 #        "id"       => id,
 #        "label"    => name_parts.join("."),
 #        "page_number" => page_num,
 #        "is_document" => false,
 #        "description" => "This is a test file generated as part of the development on the ruby IiifS3 Gem. <b> This should be bold.</b>"
 #    }

 #  if is_paged
 #    obj["section"] = "p#{page_num}"
 #    obj["section_label"] = "Page #{page_num}"
 #  end
 