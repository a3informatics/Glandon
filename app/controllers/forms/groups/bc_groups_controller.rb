require 'controller_helpers.rb'

class Forms::Groups::BcGroupsController < ManagedItemsController

  include DatatablesHelpers
  include ControllerHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::BcGroupsController

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find_full(protect_from_bad_id(params))
    bc = bc.update_with_clone(update_params, form)
    if bc.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: bc.to_h, ids: form.modified_uris_as_ids}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(bc.errors)}, :status => 200
    end
  end

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find_full(protect_from_bad_id(params))
    parent = class_for_id(the_params[:parent_id]).find_full(Uri.new(id:the_params[:parent_id]))
    result = parent.move_up_with_clone(bc, form)
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
    bc = Form::Group::Bc.find_full(protect_from_bad_id(params))
    parent = class_for_id(the_params[:parent_id]).find_full(Uri.new(id:the_params[:parent_id]))
    result = parent.move_down_with_clone(bc, form)
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: "", ids: form.modified_uris_as_ids}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def destroy
    parent = Form::Group::Normal.find_full(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find_full(protect_from_bad_id(params))
    result = bc.delete(parent, form)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, group #{bc.label} deleted.") if @lock.token.refresh == 1
    render json: {data: result, ids: form.modified_uris_as_ids}, status: 200
  end

private

  def the_params
    params.require(:bc_group).permit(:form_id, :parent_id)
  end

  def add_child_params
    params.require(:bc_group).permit(:form_id, :type, :id_set => [])
  end

  def update_params
    params.require(:bc_group).permit(:form_id, :label, :completion, :note)
  end

  def model_klass
    Form
  end

end
