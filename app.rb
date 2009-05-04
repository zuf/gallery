require 'rubygems'
require 'sinatra'
require 'fileutils'
require 'helpers'
require 'RMagick'

include Magick

# Options
set :pictures, Proc.new { File.join(root, "pictures") }
set :thumbnails, Proc.new { File.join(root, "thumbnails") }
set :thumb_size, 75

not_found do
  "404! 404!"
end

# Routes
get '/' do
  @galleries = list_dir(options.pictures)
  erb :index
end

get '/:gallery' do |gallery|
  if is_gallery? gallery
    @gallery = gallery
    @pictures = list_dir(gallery_path_for(gallery))
    raise Sinatra::NotFound if @pictures.length == 0
    erb :gallery
  else
    raise Sinatra::NotFound
  end
end

get '/:gallery/:file' do |gallery, file|
  if is_file? gallery, file
    send_file file_path_for(gallery, file)
  else
    raise Sinatra::NotFound
  end
end

get '/thumbs/:gallery/:file' do |gallery, file|
  if is_file?(gallery, file)
    thumb_path = thumb_filename_for(gallery, file, options.thumb_size)

    unless File.file? thumb_path
      image = Image.read(file_path_for(gallery, file)).first

      min = [image.columns, image.rows].min
      image.crop!(CenterGravity, min, min)
      image.resize!(options.thumb_size, options.thumb_size, LanczosFilter, 0.6)

      image.write(thumb_path)
    end

    send_file thumb_path
  else
    raise Sinatra::NotFound
  end
end
