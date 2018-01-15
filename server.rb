# Requires the Gemfile
require 'bundler'
require 'pry'
Bundler.require

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
    Dir["#{public_dir}/#{@thumb_size}/*"].map do |file|
      file.gsub /^public\//, ''
    end.sort
  end

  def fulls
    Dir["#{public_dir}/#{@full_size}/*"].map do |file|
      file.gsub /^public\//, ''
    end.sort
  end

  def filename(file)
    file.split('/').last
  end
end

class ImageResizer
  def self.resize_all(in_dir, out_dir, *resolutions)
    new(in_dir, out_dir, *resolutions).resize_all
  end

  def initialize(in_dir, out_dir, *resolutions)
    @in_dir = in_dir
    @out_dir = out_dir
    @resolutions = resolutions
  end

  def resize_all
    images.each do |file|
      image = MiniMagick::Image.open(file)
      @resolutions.each do |res|
        puts "#{file}: #{res}"
        image.resize(res)
        image.write destination(res, file)
      end
    end
  end

  private

  def images
    Dir["#{@in_dir}/*.jpg"]
  end

  def destination(res, file)
    dir = File.join(@out_dir, res.to_s)
    FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

    filename = file.split('/').last
    File.join dir, filename
  end
end


# runs resizer, then swaps in output
class ImageUpdateManager
  IMAGE_DIRS = {
    gallery:  [2000, 250],
    carousel: [2000, 740]
  }.freeze

  def initialize(source, dest)
    @source = source
    @dest = "#{dest}/#{Time.now.to_i}"
    @public_images = 'public/images'
  end

  def update
    resize_images
    symlink_new_images
    clear_incoming_images
  end

  private

  def resize_images
    IMAGE_DIRS.each do |name, resolutions|
      ImageResizer.resize_all "#{@source}/#{name}", "#{@dest}/#{name}", *resolutions
    end
  end

  def symlink_new_images
    FileUtils.ln_sf File.join('..', @dest), @public_images
  end

  def clear_incoming_images
    IMAGE_DIRS.each do |name, _|
      files = Dir[File.join(@source, name.to_s, '*')]
      FileUtils.rm files
    end
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
