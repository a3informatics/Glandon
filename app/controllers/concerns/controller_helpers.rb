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
  # @param [Array] set the history array (minimum items)
  # @param [Uri] current, the current item's uri or nil
  # @param [Uri] latest, the latest item's uri or nil
  # @result [Array] array of hashes containing the paths
  def add_history_paths(klass, set, current, latest)
    results = []
    policy = policy(klass)
    edit = policy.edit?
    status = policy(IsoManaged).status?
    delete = policy.destroy?
    set.each { |object| results << object.to_h.reverse_merge!(add_history_path(object, edit, delete, current, latest, status)) }
    results
  end

private

  # Build a set of paths for a single object. Note expects controllers to provide
  def add_history_path(object, edit, delete, current, latest, status)
    latest_item = latest.nil? ? false : latest == object.uri
    indicators = {current: object.current?, extended: false, extends: false, version_count: 0, subset: false, subsetted: false}
    result = {edit_path: "", tags_path: "", status_path: "", current_path: "", delete_path: "", show_path: "", search_path: "",
      list_cn_path: "", impact_path: "", clone_path: "", indicators: indicators}

    result[:show_path] = path_for(:show, object)
    result[:search_path] = path_for(:search, object)
    result[:list_cn_path] = path_for(:list_change_notes, object)
    result[:impact_path] = path_for(:impact, object)

    if edit && object.edit? && latest_item
      result[:edit_path] = path_for(:edit, object)
      # result[:tags_path] = path_for(:edit_tags, object)
    end
    if !current_user.is_only_community?
      result[:compare_path] = path_for(:compare, object)
    end
    if object.owned?
      result[:clone_path] = path_for(:clone, object)
    end
    if object.registered? && object.owned? && (latest_item || object.has_state.is_or_has_been_released?) && edit
      result[:status_path] = status_iso_managed_v2_path(:id => object.id, :iso_managed => {:current_id => current.nil? ? "" : current.to_id})
    end
    if object.registered? && object.can_be_current? && status
      result[:current_path] = make_current_iso_managed_v2_path(:id => object.id)
    end
    if delete && object.delete?
      result[:delete_path] = path_for(:destroy, object)
    end
    return result
  end

end
