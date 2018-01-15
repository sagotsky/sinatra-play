# bulk image resizer
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
      image = MagickWrapper.new(file)
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
