require 'rubygems'
require 'sinatra'
#require 'sinatra/r18n'
require 'sinatra/memcache'

require 'helpers'
require 'models'
require 'sass'
require 'russian'
require 'exifr'
require 'digest/sha1'

include GalleryModels

# Options
set :pictures,   Proc.new { File.join(root, "pictures") }
set :thumbnails, Proc.new { File.join(root, "thumbnails") }
#set :default_locale, 'ru'

set :cache_server, "localhost:11211"
set :cache_namespace, "sinatra-gallery"
set :cache_enable, true
#set :cache_logging, false
set :cache_default_expiry, 3600
set :cache_default_compress, true

#set :development, true

not_found do
  haml :error_404
end

# Routes
get '/' do
  cache 'index' do
    @galleries = Gallery.all options.pictures
    haml :index
  end
end

get '/stylesheets/master.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  scss :stylesheet
end

get '/:gallery' do
  cache "g#{Digest::SHA1.hexdigest(gallery_path)}" do
    begin
      @gallery = Gallery.new(gallery_path)
    rescue GalleryModels::Error
      raise Sinatra::NotFound
    end

    if @gallery.pictures.length == 0
      haml :gallery_no_pictures
    else
      @title = @gallery.title
      haml :gallery
    end
  end
end

get '/:gallery/:file' do
  begin
    @picture = Picture.new(picture_path)
  rescue GalleryModels::Error
    raise Sinatra::NotFound
  end

  send_file @picture.path
end

get '/thumbs/:gallery/:file' do
  #cache "t#{Digest::SHA1.hexdigest(picture_path)}", :expiry => 300, :compress => false do
    begin
        @picture = Picture.new(picture_path)
        send_file @picture.thumbnail(options.thumbnails)
    rescue GalleryModels::Error
      raise Sinatra::NotFound
    end
  #end
end
