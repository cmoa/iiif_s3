module IiifS3
  class ImageRecord
    attr_accessor :id
    attr_accessor :label
    attr_accessor :is_document
    attr_accessor :description
    attr_accessor :attribution
    attr_accessor :logo
    
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

    def image_path
      @path
    end

    def path=(_path)
      raise IiifS3::Error::InvalidImageData unless _path && File.exist?(_path)
      @path = _path
    end

    def is_document
      return !!@is_document
    end

    def section
      @section || DEFAULT_CANVAS_LABEL
    end

    def section_label
      @section_label || DEFAULT_CANVAS_LABEL
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