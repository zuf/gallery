module GalleryModels
  require 'yaml'
  require 'RMagick'
  require 'digest/sha1'

  DEFAULT_THUMB_SIZE = 96
  PICTURE_FILETYPES  = %w{jpg jpeg gif png tif tiff cr2}

  class Gallery
    attr_reader :path, :dir, :title, :info

    def self.all(dir)
      galleries = Array.new

      Dir.entries(dir).each do |entry|
        path = File.join(dir, entry)
        galleries << self.new(path) if !entry.match(/^\./) && File.directory?(path)
      end

      galleries.sort do |x,y|
        y.mtime <=> x.mtime
      end
    end

    def initialize(path)
      raise GalleryNotFoundError, "No such directory" unless File.directory?(path)

      begin
        @info = YAML.load_file(File.join(path, "gallery.yml"))
      rescue
        @info = Hash.new
      end

      @path  = path
      @dir   = File.basename(path)
      @title = @info["title"] ||= File.basename(path)
    end

    def pictures
      unless @pictures
        @pictures = Array.new

        Dir.entries(self.path).sort.each do |entry|
          path = File.join(self.path, entry)
          @pictures << Picture.new(path, :gallery => self) if File.file?(path) && PICTURE_FILETYPES.include?(Picture.clean_extname(path))
        end
      end

      @pictures
    end

    def mtime
      @mtime ||= File.mtime(self.path)
      @mtime
    end

    def to_s
      self.title
    end

    def min_time
      unless @min_time
        pictures.each do |picture|
          @min_time = picture.exif_date_time  if @min_time.nil? || picture.exif_date_time < @min_time
        end
        @min_time
      else
        @min_time
      end
    end

    def max_time
        unless @max_time
        pictures.each do |picture|
          @max_time = picture.exif_date_time  if @max_time.nil? || picture.exif_date_time > @max_time
        end
        @max_time
      else
        @max_time
      end
    end
  end

  class Picture
    attr_reader :path, :filename, :extension, :title, :gallery, :thumb_size

    def initialize(path, options={})
      raise PictureNotFoundError, "No such file" unless File.file?(path)


      @path       = path
      @filename   = File.basename(path)
      @extension  = self.class.clean_extname(path)
      @title      = @filename
      @gallery    = options[:gallery] || Gallery.new(File.dirname(path))
      @thumb_size = options[:thumb_size] || DEFAULT_THUMB_SIZE
    end

    def thumbnail(thumbnails_path, raw_previews_dir=nil)
      path = self.thumb_path(thumbnails_path, 'jpg')

      unless File.file? path
        if raw?
          extract_previews
          image = Magick::Image.read(self.preview_path(1)).first
        else      
          image = Magick::Image.read(self.path).first
        end
        
        image.resize_to_fill! self.thumb_size
        image.write(path)
      end

      path
    end

    def thumb_path(base_path, extension=nil)
      File.join(base_path, self.thumb_filename(extension))
    end

    def exif_date_time
      #unless @exif_date_time
      #  @exif = EXIFR::JPEG.new path
      #  @exif_date_time = @exif.date_time_original || @exif.date_time
      #else
      #  @exif_date_time
      #end


      unless @exif_date_time
        @image = Exiv2::ImageFactory.open path
        @image.read_metadata
        #@exif_date_time = @exif.date_time_original || @exif.date_time        
        exif_date = @image.exif_data['Exif.Photo.DateTimeOriginal'] || @image.exif_data['Exif.Photo.DateTimeDigitized'] || @image.exif_data['Exif.Image.DateTime']
        if exif_date
          @exif_date_time = DateTime.strptime(exif_date, '%Y:%m:%d %H:%M:%S')
        else
          @exif_date_time = File.mtime(path).to_datetime
        end
        @exif_date_time 
      else
        @exif_date_time
      end
    end

    def thumb_filename(extension=nil)
      digest = Digest::SHA1.hexdigest("#{self.gallery.dir}#{self.filename}#{self.thumb_size}").to_i.to_s(36)#[(0..8)]
      "#{digest}.#{extension || self.extension}"
    end
    
    def extract_previews(numbers = [1,3])
      system "exiv2 -f -l '#{settings.raw_previews}' -e p#{numbers.join(',')} ex '#{path}'"
    end
    
    def preview_path(number=1)
      #path.gsub(/\.CR2$/i, "-preview#{number}.jpg")
      File.join settings.raw_previews, filename.gsub(/\.#{extension}$/i, "-preview#{number}.jpg")
    end  
    
    def raw?
      cr2? # || other raw types
    end
    
    def cr2?
      @extension == 'cr2'
    end  
    
    def path_to_browser_compatible_format
      if raw?
        preview_path(3)
      else
        path
      end
    end

    def to_s
      self.filename
    end

    def self.clean_extname(path)
      begin
        File.extname(path)[1..9].downcase
      rescue NoMethodError
        ""
      end
    end
  end

  # Exceptions
  class Error < RuntimeError; end
  class GalleryNotFoundError < Error; end
  class PictureNotFoundError < Error; end
end
