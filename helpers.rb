require 'sinatra/base'
require 'digest/sha1'

module Sinatra
  module GalleryHelpers
    def gallery_path_for(gallery)
      File.join(options.pictures, gallery)
    end

    def file_path_for(gallery, file)
      File.join(options.pictures, gallery, file)
    end

    def thumb_filename_for(gallery, file, dimensions)
      File.join(options.thumbnails, picture_hash(gallery, file, dimensions)+File.extname(file))
    end

    def is_gallery?(gallery)
      File.directory? gallery_path_for(gallery)
    end

    def is_file?(gallery, file)
      File.file? file_path_for(gallery, file)
    end

    def list_dir(path)
      Dir.entries(path).delete_if{ |d| d=="." || d==".." }
    end

    def picture_hash(gallery, file, extra="")
      Digest::SHA1.hexdigest("#{gallery}#{file}#{extra}")[(0..8)]
    end
  end

  helpers GalleryHelpers
end
