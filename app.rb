require 'rubygems'
require 'sinatra'

require 'helpers'
require 'models'

include GalleryModels

# Options
set :pictures,   Proc.new { File.join(root, "pictures") }
set :thumbnails, Proc.new { File.join(root, "thumbnails") }
set :thumb_size, 75

not_found do
  "404! 404!"
end

# Routes
get '/' do
  @galleries = Gallery.all options.pictures
  erb :index
end

get '/:gallery' do
  begin
    @gallery = Gallery.new(gallery_path)
  rescue GalleryModels::Error
    raise Sinatra::NotFound
  end

  @title = @gallery.title

  erb :gallery
end

get '/:gallery/:file' do
  begin
    @picture = Picture.new(picture_path)
  rescue GalleryModels::Error
    raise Sinatra::NotFound
  end

  send_file @picture.path
end

get '/thumbs/:gallery/:file' do |gallery, file|
  begin
    @picture = Picture.new(picture_path)
    send_file @picture.thumbnail(options.thumbnails)
  rescue GalleryModels::Error
    raise Sinatra::NotFound
  end
end
