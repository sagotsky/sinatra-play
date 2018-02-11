# Requires the Gemfile
require 'bundler'
require 'pry'

require_relative 'lib/init'
Bundler.require

# set :environment, :development
# configure :development do
#   enable :logging, :dump_errors, :raise_errors
# end

module ImageCollections
  def self.gallery
    ImageCollection.new('images/gallery', {thumb: 250, full: 2000})
  end

  def self.carousel
    ImageCollection.new('images/carousel', {thumb: 740, full: 2000})
  end
end

get '/' do
  @carousel_images = ImageCollections.carousel.group_by_resolution
  @body_class = 'home'

  erb :index
end

get '/gallery' do
  @gallery_images = ImageCollections.gallery.group_by_resolution
  @body_class = 'gallery'

  erb :gallery
end

get '/about' do
  @body_class = 'about'

  erb :about
end

# get '/test' do
#   output = "before: #{Time.now}"
#   ImageUpdateManager.new('inbox/', '_resized').update
#   output << "after: #{Time.now}"

#   output
# end

# list all images in inbox and whether they're converted.  maybe the timestamp isn't the best idea?
# maybe that page could post the dest each time?
# or maybe it could loop over originals and skip items that were converted?
get '/admin' do
  # @image_inbox = ImageInbox.new('inbox/gallery', '_resized/gallery', 250, 2000)
  @image_inbox = ImageInbox.new('inbox/gallery', ImageCollections.gallery)

  erb :admin
end

get '/admin/image-inbox.json' do
  content_type :json

  # @gallery_inbox = ImageInbox.new('inbox/gallery', '_resized/gallery', 250, 2000)
  # @carousel_inbox = ImageInbox.new('inbox/carousel', '_resized/carousel', 740, 2000)

  @gallery_inbox =  ImageInbox.new('inbox/gallery', ImageCollections.gallery)
  @carousel_inbox = ImageInbox.new('inbox/carousel', ImageCollections.carousel)

  [@gallery_inbox, @carousel_inbox].map(&:to_h).reduce(&:merge).to_json
end

post '/admin/resize-image.json' do
  content_type :json

  {status: :ok}.to_json
end
#

__END__
get '/hello-world.json' do
  content_type :json # Content-Type: application/json;charset=utf-8

  # Use to_json to generate JSON based on the Ruby hash
  {greeting: 'Hello World!'}.to_json
end

TODO

* Admin page
** List of files.  Ajaxily convert them.  Waiting 10 min without ajax is too much

* FsReader
** Some sort of file system reader.  Give it a subdir, queyr it to get files out

* ImageCollection
** Instead of finding images in subdirs by resolution, an image collection has a dir for thumbs and full.  Maybe that's overridable.
** @gallery = ImageCollection.new('images/gallery', thumb: 250, full: 2000)
** maybe the collection knows about originals too?
