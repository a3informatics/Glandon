require 'controller_helpers.rb'

class Forms::Groups::CommonGroupsController < ManagedItemsController

  include DatatablesHelpers
  include ControllerHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::CommonGroupsController

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    common = Form::Group::Common.find(protect_from_bad_id(params))
    common = common.update(update_params)
    if common.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: common.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(common.errors)}, :status => 200
    end
  end

  def destroy
    parent = Form.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    common = Form::Group::Common.find(protect_from_bad_id(params))
    result = common.delete(parent)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, group #{common.label} deleted.") if @lock.token.refresh == 1
    render json: {data: result }, status: 200
  end

private
  
  def the_params
    params.require(:common_group).permit(:form_id, :parent_id)
  end

  def update_params
    params.require(:common_group).permit(:form_id, :label)
  end

  def model_klass
    Form
  end

end
