class ImageInbox
  def initialize(directory, image_collection)
    @directory = directory
    @image_collection = image_collection
    @resized_dir = 'resized/' + directory
    @name = directory.split('/').last
  end

  # select inbox files that aren't in gallery or are newer than gallery file
  def to_h
    {@name => files_to_update}
  end

  private

  def files_to_update
    inbox_files.select do |file|
      name = filename(file)

      if gallery_files_mtimes.keys.include?(name)
        File.mtime(file) >= gallery_files_mtimes[name]
      else
        true
      end
    end
  end

  def inbox_files
    Dir[File.join(@directory, '*')]
  end

  def gallery_files_mtimes
    @image_collection.file_names_mtimes
  end

  def filename(filepath)
    filepath.split('/').last
  end
end
