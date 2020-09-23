require 'controller_helpers.rb'

class Forms::Groups::NormalGroupsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = Forms::Groups::NormalGroupsController

  include ControllerHelpers

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    normal = normal.update(update_params)
    if normal.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: normal.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(normal.errors)}, :status => 200
    end
  end

  def add_child
    form = Form.find_minimum(add_child_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    new_child = normal.add_child(add_child_params)
    return true if item_errors(normal)
    AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: format_data(new_child)}, :status => 200
  end

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    normal = normal.move_up(the_params[:parent_id])
    if normal.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => normal.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    normal = normal.move_down(the_params[:parent_id])
    if normal.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => normal.errors.full_messages}, :status => 422
    end
  end

  def destroy
    parent = Form.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    normal.delete(parent)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, group #{normal.label} deleted.") if @lock.token.refresh == 1
    render json: {data: "" }, status: 200
  end

private

  def format_data(data)
    data.is_a?(Array) ? data : data.to_h
  end

  def the_params
    params.require(:normal_group).permit(:form_id, :parent_id)
  end

  def add_child_params
    params.require(:normal_group).permit(:form_id, :type, :id_set => [])
  end

  def update_params
    params.require(:normal_group).permit(:form_id, :label, :completion, :note, :repeating, :optional)
  end

  def model_klass
    Form
  end

end
