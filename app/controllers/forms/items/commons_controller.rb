require 'controller_helpers.rb'

class Forms::Items::CommonsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::CommonsController"

  include ControllerHelpers

  def update
    form = Form.find_full(the_params[:form_id])
    return true unless check_lock_for_item(form)
    common = Form::Item::Common.find(protect_from_bad_id(params))
    common = common.update(update_params)
    if common.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: common.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(common.errors)}, :status => 200
    end
  end

private

  def the_params
    params.require(:common).permit(:form_id)
  end

  def update_params
    params.require(:common).permit(:completion, :note)
  end

  def model_klass
    Form
  end

end
