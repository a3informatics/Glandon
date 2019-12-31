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

  # Get History Paths
  #
  # @param [Class] klass the relevant model class and thus the policy nlass
  # @params [Symbol] controller the relevant controller class name
  # @params [Array] set the history array (minimum items)
  # @params [Object] current, the current item's uri
  # @result [Array] array of hashes containing the paths
  def add_history_paths(klass, set, current)
    results = []
    policy = policy(klass)
    edit = policy.edit?
    delete = policy.destroy?
    set.each { |object| results << object.to_h.reverse_merge!(add_history_path(object, edit, delete, current)) }
    results
  end

private

  # Build a set of paths for a single object. Note expects controllers to provide
  def add_history_path(object, edit, delete, current)
    result = {}
    latest = object.latest?
    result[:show_path] = path_for(:show, object)
    #result[:view_path] = path_for(controller, :view, object) <<< Removed
    result[:search_path] = path_for(:search, object)
    if edit && object.edit? && latest
      result[:edit_path] = path_for(:edit, object)
      result[:tags_path] = path_for(:edit_tags, object)
    else
      result[:edit_path] = ""
      result[:tags_path] = ""
    end
    if object.registered? && object.owned? && latest && edit
      result[:status_path] = status_iso_managed_v2_path(:id => object.id, :iso_managed => {:current_id => current.nil? ? "" : current.to_id})
    else
      result[:status_path] = ""
    end
    if delete && object.delete?
      result[:delete_path] = path_for(:destroy, object)
    else
      result[:delete_path] = ""
    end
    return result
  end

end
