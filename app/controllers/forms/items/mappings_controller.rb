require 'controller_helpers.rb'

class Forms::Items::MappingsController < ManagedItemsController

  include DatatablesHelpers

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
      render :json => {:fieldErrors => format_editor_errors(mapping.errors)}, :status => 200
    end
  end

  def move_up
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    mapping = Form::Item::Mapping.find(protect_from_bad_id(params))
    mapping = mapping.move_up(move_params[:parent_id])
    if mapping.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => mapping.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    mapping = Form::Item::Mapping.find(protect_from_bad_id(params))
    mapping = mapping.move_down(move_params[:parent_id])
    if mapping.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => mapping.errors.full_messages}, :status => 422
    end
  end

  def destroy
    mapping = Form::Item::Mapping.find(protect_from_bad_id(params))
    parent = Form::Group.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    mapping.delete(parent)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, item #{mapping.label} deleted.") if @lock.token.refresh == 1
    render json: {data: "" }, status: 200
  end

private

  def the_params
    params.require(:mapping).permit(:form_id, :parent_id)
  end

  def update_params
    params.require(:mapping).permit(:form_id, :label, :mapping)
  end

  def model_klass
    Form
  end

end
