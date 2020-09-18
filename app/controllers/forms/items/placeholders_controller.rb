require 'controller_helpers.rb'

class Forms::Items::PlaceholdersController < ManagedItemsController

  include DatatablesHelpers

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
      render :json => {:fieldErrors => format_editor_errors(placeholder.errors)}, :status => 200
    end
  end

  def move_up
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    placeholder = Form::Item::Placeholder.find(protect_from_bad_id(params))
    placeholder = placeholder.move_up(move_params[:parent_id])
    if placeholder.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => placeholder.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    placeholder = Form::Item::Placeholder.find(protect_from_bad_id(params))
    placeholder = placeholder.move_down(move_params[:parent_id])
    if placeholder.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => placeholder.errors.full_messages}, :status => 422
    end
  end

private
  
  def move_params
    params.require(:placeholder).permit(:form_id, :parent_id)
  end

  def update_params
    params.require(:placeholder).permit(:form_id, :label, :free_text)
  end

  def model_klass
    Form
  end

end
