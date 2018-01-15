# Requires the Gemfile
require 'bundler'
require 'pry'

require_relative 'lib/init'
Bundler.require

# set :environment, :development
# configure :development do
#   enable :logging, :dump_errors, :raise_errors
# end


get '/' do
  @carousel_images = ImageFinder.new('images/carousel', 740, 2000).thumbs_and_full
  @body_class = 'home'

  erb :index
end

get '/gallery' do
  @gallery_images = ImageFinder.new('images/gallery', 250, 2000).thumbs_and_full
  @body_class = 'gallery'

  erb :gallery
end

get '/about' do
  @body_class = 'about'

  erb :about
end

get '/test' do
  output = "before: #{Time.now}"
  ImageUpdateManager.new('inbox/', '_resized').update
  output << "after: #{Time.now}"

  output
end

# list all images in inbox and whether they're converted.  maybe the timestamp isn't the best idea?
get '/admin' do
  @image_inbox = ImageInbox.new

  erb :admin
end

__END__
get '/hello-world.json' do
  content_type :json # Content-Type: application/json;charset=utf-8

  # Use to_json to generate JSON based on the Ruby hash
  {greeting: 'Hello World!'}.to_json
end


# existing pages
get '/index' do
end

get '/home' do
end

get '/about' do
end

get '/admin-update' do
  # can we resize images on dh?
end

get '/status' do
  # see status of image conversion.  maybe we can have an import directory and a resized dir.  magick one image at a time, move when done
end
