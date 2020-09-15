require 'controller_helpers.rb'

class Forms::Items::MappingsController < ManagedItemsController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::MappingsController"

  include ControllerHelpers

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    mapping = Form::Item::Mapping.find(protect_from_bad_id(params))
    mapping = mapping.update(update_params)
    if mapping.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: mapping.to_h}, :status => 200
    else
      render :json => {errors: mapping.errors.full_messages}, :status => 200
    end
  end

private

  def update_params
    params.require(:mapping).permit(:form_id, :completion, :note, :mapping)
  end

  def model_klass
    Form
  end

end
