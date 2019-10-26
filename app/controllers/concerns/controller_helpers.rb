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
  # @param [Class] klass the klass
  # @params [Symbol] controller controller name
  # @params [Array] set the history array (minimum items)
  # @params [Object] current, the current item's uri
  # @result [Array] array of hashes containing the paths
  def add_history_paths(klass, controller, set, current)
    results = []
    policy = policy(klass)
    edit = policy.edit?
    delete = policy.destroy?
    set.each do |object|
      results << object.to_h.reverse_merge!(add_history_path(controller, object, edit, delete, current))
    end
    results
  end

private

  # Build a set of paths for a single object
  def add_history_path(controller, object, edit, delete, current)
    result = {}
    result[:show_path] = path_for(controller, :show, object)
    #result[:view_path] = path_for(controller, :view, object) <<< Removed
    result[:search_path] = path_for(controller, :search, object)
    if edit && object.edit? && object.latest?
      result[:edit_path] = path_for(controller, :edit, object)
      result[:tags_path] = edit_tags_iso_managed_index_path(:id => object.uri.fragment, :namespace => object.uri.namespace)
    else
      result[:edit_path] = ""
      result[:tags_path] = ""
    end      
    if object.registered? && edit
      result[:status_path] = status_iso_managed_v2_path(:id => object.id, :iso_managed => {:current_id => current.nil? ? "" : current.to_id})
    else
      result[:status_path] = ""
    end
    if delete && object.delete?
      result[:delete_path] = path_for(controller, :destroy, object)
    else
      result[:delete_path] = ""
    end
    return result
  end

  # Get the path for a controller action pair
  def path_for(controller, action, id)
    Rails.application.routes.url_for controller: controller, action: action, only_path: true, id: id
  end

end