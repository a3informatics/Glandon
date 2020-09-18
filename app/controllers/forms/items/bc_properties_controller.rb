require 'controller_helpers.rb'

class Forms::Items::BcPropertiesController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::BcPropertiesController"

  include ControllerHelpers

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_property = Form::Item::BcProperty.find(protect_from_bad_id(params))
    bc_property = bc_property.update(update_params)
    if bc_property.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: bc_property.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(bc_property.errors)}, :status => 200
    end
  end

  def move_up
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_property = Form::Item::BcProperty.find(protect_from_bad_id(params))
    bc_property = bc_property.move_up(move_params[:parent_id])
    if bc_property.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => bc_property.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_property = Form::Item::BcProperty.find(protect_from_bad_id(params))
    bc_property = bc_property.move_down(move_params[:parent_id])
    if bc_property.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => bc_property.errors.full_messages}, :status => 422
    end
  end

private
  
  def move_params
    params.require(:bc_property).permit(:form_id, :parent_id)
  end

  def update_params
    params.require(:bc_property).permit(:form_id, :completion, :note, :enabled, :optional)
  end

  def model_klass
    Form
  end

end
