module GalleryModels
  require 'yaml'
  require 'RMagick'
  require 'digest/sha1'

  DEFAULT_THUMB_SIZE = 75
  PICTURE_FILETYPES  = %w{jpg jpeg gif png tif tiff}

  class Gallery
    attr_reader :path, :dir, :title, :info

    def self.all(dir)
      galleries = Array.new

      Dir.entries(dir).each do |entry|
        path = File.join(dir, entry)
        galleries << self.new(path) if !entry.match(/^\./) && File.directory?(path)
      end

      galleries
    end

    def initialize(path)
      raise GalleryNotFoundError, "No such file or directory" unless File.directory?(path)

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

        Dir.entries(self.path).each do |entry|
          path = File.join(self.path, entry)
          @pictures << Picture.new(path, :gallery => self) if File.file?(path) && PICTURE_FILETYPES.include?(Picture.clean_extname(path))
        end
      end

      @pictures
    end

    def to_s
      self.title
    end
  end

  class Picture
    attr_reader :path, :filename, :extension, :gallery, :thumb_size

    def initialize(path, options={})
      @path       = path
      @filename   = File.basename(path)
      @extension  = self.class.clean_extname(path)
      @gallery    = options[:gallery] || Gallery.new(path[/^(.+?)[^\/]+$/, 1])
      @thumb_size = options[:thumb_size] || DEFAULT_THUMB_SIZE
    end

    def thumbnail(thumbnails_path)
      path = self.thumb_path(thumbnails_path)

      unless File.file? path
        image = Magick::Image.read(self.path).first
        image.resize_to_fill! self.thumb_size
        image.write(path)
      end

      path
    end

    def thumb_path(base_path)
      digest = Digest::SHA1.hexdigest("#{self.gallery.dir}#{self.filename}#{self.thumb_size}")[(0..8)]
      File.join(base_path, "#{digest}.#{self.extension}")
    end

    def to_s
      self.filename
    end

    def self.clean_extname(path)
      File.extname(path)[1..9].downcase
    end
  end

  # Exceptions
  class Error < RuntimeError; end
  class GalleryNotFoundError < Error; end
  class PictureNotFoundError < Error; end
end