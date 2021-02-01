require 'controller_helpers.rb'

class ManagedCollectionsController < ManagedItemsController

  include ControllerHelpers
  include DatatablesHelpers

  before_action :authenticate_and_authorized

  def index
    super
  end

  def history
    super
  end

  def show
    @mc = ManagedCollection.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_managed_collection_path(@mc)
    @edit_tags_path = path_for(:edit_tags, @mc)
    @close_path = history_managed_collections_path(managed_collection: { identifier: @mc.has_identifier.identifier, scope_id: @mc.scope })
  end

  def show_data
    @mc = ManagedCollection.find_minimum(protect_from_bad_id(params))
    render json: {data: @mc.managed_items}, status: 200
  end

  def create
    mc = ManagedCollection.create(the_params)
    if mc.errors.empty?
      AuditTrail.create_item_event(current_user, mc, mc.audit_message(:created))
      path = history_managed_collections_path({managed_collection: {identifier: mc.scoped_identifier, scope_id: mc.scope.id}})
      render :json => {data: {history_path: path, id: mc.id}}, :status => 200
    else
      render :json => {errors: mc.errors.full_messages}, :status => 422
    end
  end

  def edit
    @mc = ManagedCollection.find_with_properties(protect_from_bad_id(params))
    respond_to do |format|
      format.html do
        return true unless edit_lock(@mc)
        @mc = @edit.item
        @edit_tags_path = path_for(:edit_tags, @mc)
        @close_path = history_managed_collections_path({ managed_collection:
            { identifier: @mc.scoped_identifier, scope_id: @mc.scope } })
      end
      format.json do
        @mc = ManagedCollection.find_full(@mc.id)
        return true unless check_lock_for_item(@mc)
        render :json => { data: @mc.managed_items }, :status => 200
      end
    end
  end

  def add
    mc = ManagedCollection.find_full(protect_from_bad_id(params))
    return true unless check_lock_for_item(mc)
    set_before = mc.managed_items
    item = mc.add_item(items_params[:id_set])
    if item.errors.empty?
      AuditTrail.create_item_event(current_user, mc, "Item(s) added to Managed Collection.")
      set_after = mc.managed_items
      result = set_after - set_before
      render :json => {data: result}, :status => 200
    else
      render :json => {errors: item.errors.full_messages}, :status => 422
    end
  end

  def remove
    mc = ManagedCollection.find_full(protect_from_bad_id(params))
    return true unless check_lock_for_item(mc)
    result = mc.remove_item(items_params[:id_set])
    if result.errors.empty?
      AuditTrail.create_item_event(current_user, sdtm_sponsor_domain, "Item(s) removed from Managed Collection.")
      render :json => {data: []}, :status => 200
    else
      render :json => {errors: result.errors.full_messages}, :status => 422
    end
  end

private

  # Strong parameters, general
  def the_params
    params.require(:managed_collection).permit(:identifier, :label, :offset, :count, :scope_id)
  end

  def items_params
    params.require(:managed_collection).permit(:id_set => [])
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return managed_collection_path(object)
      when :edit
        return edit_managed_collection_path(id: object.id)
      #when :destroy
        #return managed_collection_path(object)
      when :edit_tags
        return object.supporting_edit? ? edit_tags_iso_concept_path(id: object.id) : ""
      else
        return super
    end
  end

  # Model class
  def model_klass
    ManagedCollection
  end

  # History path
  def history_path_for(identifier, scope_id)
    return {history_path: history_managed_collections_path({managed_collection:{identifier: identifier, scope_id: scope_id}})}
  end

  # Close path
  def close_path_for
    managed_collections_path
  end

end
