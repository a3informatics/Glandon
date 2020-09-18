require 'controller_helpers.rb'

class Forms::Items::QuestionsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::QuestionController"

  include ControllerHelpers

  def update
    form = Form.find_full(update_params[:form_id])
    return true unless check_lock_for_item(form)
    question = Form::Item::Question.find(protect_from_bad_id(params))
    question = question.update(update_params)
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
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    question = Form::Item::Question.find(protect_from_bad_id(params))
    question = question.move_up(move_params[:parent_id])
    if question.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => question.errors.full_messages}, :status => 422
    end
  end

  def move_down
    form = Form.find_minimum(move_params[:form_id])
    return true unless check_lock_for_item(form)
    question = Form::Item::Question.find(protect_from_bad_id(params))
    question = question.move_down(move_params[:parent_id])
    if question.errors.empty?
      AuditTrail.update_item_event(current_user, form, form.audit_message(:updated)) if @lock.first_update?
      render :json => {data: ""}, :status => 200
    else
      render :json => {:errors => question.errors.full_messages}, :status => 422
    end
  end

private

  def move_params
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
