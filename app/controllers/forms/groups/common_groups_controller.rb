require 'controller_helpers.rb'

class Forms::Groups::CommonGroupsController < ManagedItemsController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::CommonGroupsController

  include ControllerHelpers

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    common = Form::Group::Common.find(protect_from_bad_id(params))
    common = common.update(update_params)
    if common.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: common.to_h}, :status => 200
    else
      render :json => {errors: common.errors.full_messages}, :status => 200
    end
  end

private

  def update_params
    params.require(:common_group).permit(:form_id, :label, :completion, :note)
  end

  def model_klass
    Form
  end

end
