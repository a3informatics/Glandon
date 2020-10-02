require 'controller_helpers.rb'

class Forms::Items::TextLabelsController < ManagedItemsController

  include DatatablesHelpers
  include ControllerHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::TextLabelsController"

  def update
    form = Form.find_full(update_params[:form_id])
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

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    text_label = Form::Item::TextLabel.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_up(text_label)
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
    text_label = Form::Item::TextLabel.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_down(text_label)
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def destroy
    text_label = Form::Item::TextLabel.find(protect_from_bad_id(params))
    parent = Form::Group.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    result = text_label.delete(parent)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, item #{text_label.label} deleted.") if @lock.token.refresh == 1
    render json: {data: result }, status: 200
  end

private

  def the_params
    params.require(:text_label).permit(:form_id, :parent_id)
  end

  def update_params
    params.require(:text_label).permit(:form_id, :label, :label_text)
  end

  def model_klass
    Form
  end

end
