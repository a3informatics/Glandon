require 'controller_helpers.rb'

class Forms::Items::CommonsController < ManagedItemsController

  include ControllerHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::CommonsController"

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    common = Form::Item::Common.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_up(common)
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
    common = Form::Item::Common.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_down(common)
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def restore
    common = Form::Item::Common.find(protect_from_bad_id(params))
    parent = Form::Group.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    result = common.delete(parent, form)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, item #{common.label} deleted.") if @lock.token.refresh == 1
    render json: {data: result }, status: 200
  end


private
  
  def the_params
    params.require(:common).permit(:form_id, :parent_id)
  end

  def model_klass
    Form
  end

end
