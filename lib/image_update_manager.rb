# runs resizer on all our sets of images, then swaps in output in public image dir
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

