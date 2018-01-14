# Requires the Gemfile
require 'bundler'
Bundler.require

# By default Sinatra will return the string as the response.
get '/' do
  erb :index
end

# can we list files?
get '/gallery' do
  # Dir['images/*'].to_s
  erb :gallery
end

get '/about' do
  erb :about
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
