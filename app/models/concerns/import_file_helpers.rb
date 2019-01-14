# Import File Helpers.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module ImportFileHelpers

  # Save an import file in the configured directory. Will be saved as a YAML file.
  #
  # @param [String] data the data structure to be saved
  # @param [String] filename the filename to be used.
  # @return [String] the full file path of the file saved.
  def self.save_errors(errors, filename)
    path_plus_filename = full_path(filename)
    File.open(path_plus_filename, 'wb') do |file|
      file << errors.to_yaml
    end
    return path_plus_filename.to_s
  end
      
  # Read an error file. Assumed to be a YAML file.
  #
  # @param [String] path the full path of the filen to be read.
  # @return [String] the data read.
  def self.read_errors(path)
    YAML.load_file(path)
  end

  # Move a file
  #
  # @param [String] src the full path of the file to be moved.
  # @param [String] filename the filename for the destination file.
  # @return [String] the data read.
  def self.move(src, filename)
    FileUtils.mv(src, full_path(filename))
  end

private

  # Build the full path for the file.
  def self.full_path(filename)
    Rails.root.join(APP_CONFIG['import_files'], filename)
  end

end