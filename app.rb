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

require 'exiv2'

# Time hack
require 'date'
class Time
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end


include GalleryModels



# Options
set :pictures,   Proc.new { File.join(root, "pictures") }
set :thumbnails, Proc.new { File.join(root, "thumbnails") }
set :raw_previews, Proc.new { File.join(root, "raw_previews") }
set :half_previews, Proc.new { File.join(root, "half_previews") }
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
    @galleries = Gallery.all settings.pictures
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
    send_file @picture.path_to_browser_compatible_format
  rescue GalleryModels::Error
    raise Sinatra::NotFound
  end
end

get '/thumbs/:gallery/:file' do
  #cache "t#{Digest::SHA1.hexdigest(picture_path)}", :expiry => 300, :compress => false do
    begin
        @picture = Picture.new(picture_path)
        send_file @picture.thumbnail
    rescue GalleryModels::Error
      raise Sinatra::NotFound
    end
  #end
end
