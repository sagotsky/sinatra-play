# Requires the Gemfile
require 'bundler'
Bundler.require

# By default Sinatra will return the string as the response.
get '/' do
  @carousel_images = ImageFinder.new('images/carousel', 740, 2000).thumbs_and_full
  erb :index#, carousel_images: images
end

# can we list files?
get '/gallery' do
  # Dir['images/*'].to_s
  erb :gallery
end

get '/about' do
  erb :about
end

class ImageFinder
  # maybe thumb, full could be *resolution and this returns whatever resolutions were specified in that order?
  def initialize(dir, thumb_size, full_size)
    @dir = dir
    @thumb_size = thumb_size
    @full_size = full_size
  end

  def thumbs_and_full
    thumbs_hash = thumbs.each_with_object({}) do |thumb, hash|
      hash[filename(thumb)] = thumb
    end

    fulls.each_with_object({}) do |full, hash|
      name = filename(full)
      thumb = thumbs_hash.delete(name)
      if thumb
        hash[thumb] = full
      end
    end
  end

  private

  def public_dir
    "public/#{@dir}"
  end

  def thumbs
    sub = "#{@thumb_size}x#{@thumb_size}"
    Dir["#{public_dir}/#{sub}/*"].map do |file|
      file.gsub /^public\//, ''
    end.sort
  end

  def fulls
    sub = "#{@full_size}x#{@full_size}"
    Dir["#{public_dir}/#{sub}/*"].map do |file|
      file.gsub /^public\//, ''
    end.sort
  end

  def filename(file)
    file.split('/').last
  end
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
