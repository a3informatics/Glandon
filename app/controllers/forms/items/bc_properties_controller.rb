require 'controller_helpers.rb'

class Forms::Items::BcPropertiesController < ManagedItemsController

  include DatatablesHelpers
  include ControllerHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::BcPropertiesController"

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_property = Form::Item::BcProperty.find(protect_from_bad_id(params))
    bc_property = bc_property.update_with_clone(update_params, form)
    if bc_property.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: bc_property.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(bc_property.errors)}, :status => 200
    end
  end

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_property = Form::Item::BcProperty.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_up_with_clone(bc_property, form)
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_property = Form::Item::BcProperty.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_down_with_clone(bc_property, form)
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def make_common
    form = Form.find_full(the_params[:form_id])
    return true unless check_lock_for_item(form)
    bc_property = Form::Item::BcProperty.find(protect_from_bad_id(params))
    common_item = bc_property.make_common
    return true if item_errors(bc_property)
    AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: common_item}, :status => 200
  end

private
  
  def the_params
    params.require(:bc_property).permit(:form_id, :parent_id)
  end

  def update_params
    params.require(:bc_property).permit(:form_id, :completion, :note, :enabled, :optional)
  end

  def model_klass
    Form
  end

end
