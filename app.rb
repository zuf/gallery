require 'rubygems'
require 'sinatra'

require 'helpers'
require 'models'
require 'sass'
require 'russian'
require 'exifr'

include GalleryModels

# Options
set :pictures,   Proc.new { File.join(root, "pictures") }
set :thumbnails, Proc.new { File.join(root, "thumbnails") }

not_found do
  haml :error_404
end

# Routes
get '/' do
  @galleries = Gallery.all options.pictures
  haml :index
end

get '/stylesheets/master.css' do
  headers 'Content-Type' => 'text/css; charset=utf-8'
  scss :stylesheet
end

get '/:gallery' do
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

get '/:gallery/:file' do
  begin
    @picture = Picture.new(picture_path)
  rescue GalleryModels::Error
    raise Sinatra::NotFound
  end

  send_file @picture.path
end

get '/thumbs/:gallery/:file' do
  begin
    @picture = Picture.new(picture_path)
    send_file @picture.thumbnail(options.thumbnails)
  rescue GalleryModels::Error
    raise Sinatra::NotFound
  end
end
