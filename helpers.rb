require 'sinatra/base'

module Sinatra
  module GalleryHelpers
    def gallery_path
      File.join(options.pictures, params[:gallery])
    end

    def picture_path
      File.join(options.pictures, params[:gallery], params[:file])
    end
  end

  helpers GalleryHelpers
end
