class ImageCollection
  def initialize(path, resolutions_hash)
    @path = path
    @resolutions_hash = resolutions_hash
  end

  # returns
  # [{thumb: path/to/thumb/01.jpg, full: path/to/full/01.jpg}]
  def group_by_resolution
    {}.tap do |image_hashes|
      resolution_labels.map do |label|
        images_by_filename(label).each do |filename, filepath|
          image_hashes[filename] ||= {}
          image_hashes[filename][label] = filepath
        end
      end
    end.values # would the filename key be valuable?
  end

  # For each filename in collection, return min mtime
  def file_names_mtimes
    group_by_resolution.each_with_object({}) do |images, hash|
      name  = filename(images.values.first)
      mtime = images.values.map do |image|
        File.mtime('public/' + image)
      end.min

      hash[name] = mtime
    end
  end

  private

  def resolution_labels
    @resolutions_hash.keys
  end

  def images_by_filename(label)
    images(label).each_with_object({}) do |image, hash|
      hash[filename(image)] = image
    end
  end

  def images(label)
    Dir["public/#{@path}/#{label}/*"].sort.map do |f|
      f.gsub %r{^public\/}, ''
    end
  end

  def filename(filepath)
    filepath.split('/').last
  end
end
