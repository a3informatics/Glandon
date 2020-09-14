require 'controller_helpers.rb'

class OperationalReferenceV3::TucReferencesController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "OperationalReferenceV3::TucReferencesController"

  include ControllerHelpers

  def update
    form = Form.find_full(the_params[:form_id])
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

private

  def the_params
    params.require(:tuc_reference).permit(:form_id)
  end

  def update_params
    params.require(:tuc_reference).permit(:label, :optional, :enabled)
  end

  def model_klass
    Form
  end

end
