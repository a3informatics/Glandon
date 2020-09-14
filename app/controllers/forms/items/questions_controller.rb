require 'controller_helpers.rb'

class Forms::Items::QuestionsController < ManagedItemsController

  include DatatablesHelpers

  before_action :authenticate_and_authorized

  C_CLASS_NAME = "Forms::Items::QuestionController"

  include ControllerHelpers

  def update
    form = Form.find_full(the_params[:form_id])
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

private

  def the_params
    params.require(:question).permit(:form_id)
  end

  def update_params
    params.require(:question).permit(:label, :completion, :note, :datatype, :format, :question_text, :mapping)
  end

  def model_klass
    Form
  end

end
