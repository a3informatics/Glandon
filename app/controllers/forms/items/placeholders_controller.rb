require 'controller_helpers.rb'

class Forms::Items::PlaceholdersController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::PlaceholdersController"

  include ControllerHelpers

  def update
    form = Form.find_full(the_params[:form_id])
    return true unless check_lock_for_item(form)
    placeholder = Form::Item::Placeholder.find(protect_from_bad_id(params))
    placeholder = placeholder.update(update_params)
    if placeholder.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: placeholder.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(placeholder.errors)}, :status => 200
    end
  end

private

  def the_params
    params.require(:placeholder).permit(:form_id)
  end

  def update_params
    params.require(:placeholder).permit(:label, :completion, :note, :ordinal, :optional, :free_text)
  end

  def model_klass
    Form
  end

end
