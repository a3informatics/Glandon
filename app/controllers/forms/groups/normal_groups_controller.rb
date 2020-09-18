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
    if new_child.is_a?(Array) ### IMPROVE CODE ###
      return true if lock_item_errors
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
     render :json => {data: new_child}, :status => 200
    else
      return true if item_errors(new_child)
      return true if lock_item_errors
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
      render :json => {data: new_child.to_h}, :status => 200
    end
  end

  def move_up
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    normal = normal.move_up(move_params[:parent_id])
    if normal.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => normal.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    normal = Form::Group::Normal.find(protect_from_bad_id(params))
    normal = normal.move_down(move_params[:parent_id])
    if normal.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => normal.errors.full_messages}, :status => 422
    end
  end

private

  def move_params
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
