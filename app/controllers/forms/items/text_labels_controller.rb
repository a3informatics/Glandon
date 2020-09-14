require 'controller_helpers.rb'

class Forms::Items::TextLabelsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::TextLabelsController"

  include ControllerHelpers

  def update
    form = Form.find_full(the_params[:form_id])
    return true unless check_lock_for_item(form)
    text_label = Form::Item::TextLabel.find(protect_from_bad_id(params))
    text_label = text_label.update(update_params)
    if text_label.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: text_label.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(text_label.errors)}, :status => 200
    end
  end

private

  def the_params
    params.require(:text_label).permit(:form_id)
  end

  def update_params
    params.require(:text_label).permit(:label, :label_text)
  end

  def model_klass
    Form
  end

end
