require 'controller_helpers.rb'

class Forms::Items::PlaceholdersController < ManagedItemsController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::PlaceholdersController"

  include ControllerHelpers

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    placeholder = Form::Item::Placeholder.find(protect_from_bad_id(params))
    placeholder = placeholder.update(update_params)
    if placeholder.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: placeholder.to_h}, :status => 200
    else
      render :json => {errors: placeholder.errors.full_messages}, :status => 200
    end
  end

private

  def update_params
    params.require(:placeholder).permit(:form_id, :completion, :note, :free_text)
  end

  def model_klass
    Form
  end

end
