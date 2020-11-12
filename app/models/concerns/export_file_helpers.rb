# Export File Helpers.
#
# @author Dave Iberson-Hurst
# @since 2.20.2
module ExportFileHelpers

  # Save an export file in the configured directory
  #
  # @param [String] data the data to be saved
  # @param [String] filename the filename to be used.
  # @return [String] the full file path of the file saved.
  def self.save(data, filename)
    path_plus_filename = full_path(filename)
    File.open(path_plus_filename, 'wb') do |file|
      file << data
    end
    return path_plus_filename.to_s
  end

  # Following may be useful in the future
  #def self.read_export(filename)
  #  File.open(save_path(filename), 'rb') do |f|
  #    return f.read
  #  end
  #end

  #def self.full_path(filename)
  #  return full_path(filename)
  #end
  
private

  # Build the full path for the file.
  def self.full_path(filename)
    Rails.root.join(APP_CONFIG['export_files'], filename)
  end

end