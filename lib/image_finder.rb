# finds images with both full and thumbnail in a dir

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

