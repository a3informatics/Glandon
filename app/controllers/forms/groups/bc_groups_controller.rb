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

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find(protect_from_bad_id(params))
    bc = bc.move_up(the_params[:parent_id])
    if bc.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => bc.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find(protect_from_bad_id(params))
    bc = bc.move_down(the_params[:parent_id])
    if bc.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => bc.errors.full_messages}, :status => 422
    end
  end

  def destroy
    parent = Form.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc = Form::Group::Bc.find(protect_from_bad_id(params))
    bc.delete(parent)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, group #{bc.label} deleted.") if @lock.token.refresh == 1
    render json: {data: "" }, status: 200
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
