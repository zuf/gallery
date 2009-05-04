require 'sinatra/base'

module Sinatra
  module GalleryHelpers
    def gallery_path
      File.join(options.pictures, params[:gallery])
    end

    def picture_path
      File.join(options.pictures, params[:gallery], params[:file])
    end

    def gallery_url(gallery)
      "/#{gallery.dir}"
    end

    def picture_url(picture)
      "/#{picture.gallery.dir}/#{picture.filename}"
    end

    def thumb_url(picture)
      "/thumbs#{picture_url(picture)}"
    end
  end

  helpers GalleryHelpers
end
