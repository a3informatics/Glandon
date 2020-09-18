require 'controller_helpers.rb'

class Forms::Groups::BcGroupsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::BcGroupsController

  include ControllerHelpers

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find(protect_from_bad_id(params))
    bc = bc.update(update_params)
    if bc.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: bc.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(bc.errors)}, :status => 200
    end
  end

  def add_child
    form = Form.find_minimum(add_child_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_group = Form::Group::Bc.find(protect_from_bad_id(params))
    new_child = bc_group.add_child(add_child_params)
    return true if item_errors(new_child)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: new_child.to_h}, :status => 200
  end

  def move_up
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find(protect_from_bad_id(params))
    bc = bc.move_up(move_params[:parent_id])
    if bc.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => bc.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find(protect_from_bad_id(params))
    bc = bc.move_down(move_params[:parent_id])
    if bc.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => bc.errors.full_messages}, :status => 422
    end
  end

private

  def move_params
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
