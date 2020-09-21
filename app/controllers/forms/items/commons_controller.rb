require 'controller_helpers.rb'

class Forms::Items::CommonsController < ManagedItemsController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::CommonsController"

  include ControllerHelpers

  def move_up
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    common = Form::Item::Common.find(protect_from_bad_id(params))
    common = common.move_up(move_params[:parent_id])
    if common.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => common.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    common = Form::Item::Common.find(protect_from_bad_id(params))
    common = common.move_down(move_params[:parent_id])
    if common.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => common.errors.full_messages}, :status => 422
    end
  end

  def destroy
    common = Form::Item::Common.find(protect_from_bad_id(params))
    parent = Form::Group.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    common.delete(parent)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, item #{common.label} deleted.") if @lock.token.refresh == 1
    render json: {data: "" }, status: 200
  end


private
  
  def the_params
    params.require(:common).permit(:form_id, :parent_id)
  end

  def move_params
    params.require(:common).permit(:form_id, :parent_id)
  end

  def model_klass
    Form
  end

end
