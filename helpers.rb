require 'sinatra/base'

module Sinatra
  module GalleryHelpers
    def gallery_path
      File.join(settings.pictures, params[:gallery])
    end

    def picture_path
      File.join(settings.pictures, params[:gallery], params[:file])
    end

    def gallery_url(gallery)
      "/#{gallery.dir}"
    end

    def picture_url(picture)
      if picture.raw?
        "/#{picture.gallery.dir}/../#{picture.path_to_browser_compatible_format}"
        "/#{picture.gallery.dir}/#{picture.filename}"
      else
        "/#{picture.gallery.dir}/#{picture.filename}"
      end
    end

    def thumb_url(picture)
      "/thumbs#{picture_url(picture)}"
    end

    def format_date(time)
      time.strftime "%Y-%m-%d"
    end

    def datetime_format(datetime)
      Russian::strftime(datetime, "%d %B %Y %H:%M")
    end

    def date_format(datetime)
      Russian::strftime(datetime, "%d %B %Y")
    end
  end

  helpers GalleryHelpers
end
