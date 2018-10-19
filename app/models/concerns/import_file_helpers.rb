# Import File Helpers.
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module ImportFileHelpers

  # Save an import file in the configured directory. Will be saved as YAML if extension is set to "yml" 
  #  otherwise as passed.
  #
  # @param [String] data the data structure to be saved
  # @param [String] filename the filename to be used.
  # @return [String] the full file path of the file saved.
  def self.save(data, filename)
    path_plus_filename = full_path(filename)
    File.open(path_plus_filename, 'wb') do |file|
      File.extname(path_plus_filename) == ".yml" ? file << data.to_yaml : file << data
    end
    return path_plus_filename.to_s
  end

  # Read an import file. Assumed to be a YAML file.
  #
  # @param [String] path the full path of the filen to be read.
  # @return [String] the data read.
  def self.read(path)
    YAML.load_file(path)
  end

private

  # Build the full path for the file.
  def self.full_path(filename)
    Rails.root.join(APP_CONFIG['import_files'], filename)
  end

end