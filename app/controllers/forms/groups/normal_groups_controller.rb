require 'controller_helpers.rb'

class Forms::Groups::NormalGroupsController < ManagedItemsController

  include DatatablesHelpers
  include ControllerHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::NormalGroupsController

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find_full(protect_from_bad_id(params))
    normal = normal.update_with_clone(update_params, form)
    if normal.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: normal.to_h, ids: form.modified_uris_as_ids}, :status => 200
    else
      if normal.errors.has_key? :base
        render :json => {:errors => normal.errors.full_messages}, :status => 422 
      else 
        render :json => {:fieldErrors => format_editor_errors(normal.errors)}, :status => 422
      end
    end
  end

  def add_child
    form = Form.find_minimum(add_child_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find_full(protect_from_bad_id(params))
    new_child = normal.add_child_with_clone(add_child_params, form)
    return true if item_errors(normal)
    AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: format_data(new_child), ids: form.modified_uris_as_ids}, :status => 200
  end

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find_full(protect_from_bad_id(params))
    parent = class_for_id(the_params[:parent_id]).find_full(Uri.new(id:the_params[:parent_id]))
    result = parent.move_up_with_clone(normal, form)
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: "", ids: form.modified_uris_as_ids}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find_full(protect_from_bad_id(params))
    parent = class_for_id(the_params[:parent_id]).find_full(Uri.new(id:the_params[:parent_id]))
    result = parent.move_down_with_clone(normal, form)
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: "", ids: form.modified_uris_as_ids}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def destroy
    parent = Form.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    result = normal.delete(parent,form)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, group #{normal.label} deleted.") if @lock.token.refresh == 1
    render json: {data: result, ids: form.modified_uris_as_ids}, status: 200
  end

private

  def format_data(data)
    data.is_a?(Array) ? data : data.to_h
  end

  def the_params
    params.require(:normal_group).permit(:form_id, :parent_id)
  end

  def add_child_params
    params.require(:normal_group).permit(:form_id, :type, :id_set => [])
  end

  def update_params
    params.require(:normal_group).permit(:form_id, :label, :completion, :note, :repeating, :optional)
  end

  def model_klass
    Form
  end

end
