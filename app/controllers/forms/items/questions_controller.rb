require 'controller_helpers.rb'

class Forms::Items::QuestionsController < ManagedItemsController

  include DatatablesHelpers
  include ControllerHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::QuestionController"

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    question = Form::Item::Question.find(protect_from_bad_id(params))
    question = question.update_with_clone(update_params, form)
    if question.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: question.to_h}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(question.errors)}, :status => 200
    end
  end

  def add_child
    form = Form.find_minimum(add_child_params[:form_id])
    return true unless check_lock_for_item(form)
    question = Form::Item::Question.find(protect_from_bad_id(params))
    new_child = question.add_child(add_child_params)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: new_child}, :status => 200
  end

  def move_up
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    question = Form::Item::Question.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_up(question)    
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
    question = Form::Item::Question.find(protect_from_bad_id(params))
    parent = IsoConceptV2.find(the_params[:parent_id])
    result = parent.move_down(question)    
    if parent.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => parent.errors.full_messages}, :status => 422
    end
  end

  def destroy
    question = Form::Item::Question.find(protect_from_bad_id(params))
    parent = Form::Group.find(the_params[:parent_id])
    form = Form.find_minimum(the_params[:form_id])
    return true unless check_lock_for_item(form)
    result = question.delete(parent, form)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, form, "Form updated, item #{question.label} deleted.") if @lock.token.refresh == 1
    render json: {data: result }, status: 200
  end

private

  def the_params
    params.require(:question).permit(:form_id, :parent_id)
  end

  def add_child_params
    params.require(:question).permit(:form_id, :type, :id_set => [:id, :context_id])
  end

  def update_params
    params.require(:question).permit(:form_id, :label, :completion, :note, :datatype, :format, :question_text, :mapping, :optional)
  end

  def model_klass
    Form
  end

end
