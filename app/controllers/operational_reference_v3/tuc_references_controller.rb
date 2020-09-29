require 'controller_helpers.rb'

class OperationalReferenceV3::TucReferencesController < ManagedItemsController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "OperationalReferenceV3::TucReferencesController"

  include DatatablesHelpers
  include ControllerHelpers
  
  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    tuc_reference = OperationalReferenceV3::TucReference.find(protect_from_bad_id(params))
    tuc_reference = tuc_reference.update(update_params)
    if tuc_reference.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: tuc_reference.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(tuc_reference.errors)}, :status => 200
    end
  end

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    tuc_reference = OperationalReferenceV3::TucReference.find(protect_from_bad_id(params))
    tuc_reference = tuc_reference.move_up(the_params[:parent_id])
    if tuc_reference.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => tuc_reference.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    tuc_reference = OperationalReferenceV3::TucReference.find(protect_from_bad_id(params))
    tuc_reference = tuc_reference.move_down(the_params[:parent_id])
    if tuc_reference.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => tuc_reference.errors.full_messages}, :status => 422
    end
  end

  def destroy
    tuc_reference = OperationalReferenceV3::TucReference.find(protect_from_bad_id(params))
    parent = Form::Item.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    tuc_reference.delete(parent)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, item #{tuc_reference.label} deleted.") if @lock.token.refresh == 1
    render json: {data: "" }, status: 200
  end

private

  def the_params
    params.require(:tuc_reference).permit(:form_id, :parent_id)
  end

  def update_params
    params.require(:tuc_reference).permit(:form_id, :local_label, :optional, :enabled)
  end

  def model_klass
    Form
  end

end
