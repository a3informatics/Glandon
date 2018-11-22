# Controller Helpers
#
# @author Dave Iberson-Hurst
# @since 2.21.0
module ControllerHelpers

  # Get list of files in the upload directory by extension
  #
  # @param [String] ext the extension in *.xxx format
  # @return [Array] array of full path filenames.
  def upload_files(ext)
    return Dir.glob(Rails.root.join(APP_CONFIG['upload_files']) + ext).sort!
  rescue => e
    return []
  end

end