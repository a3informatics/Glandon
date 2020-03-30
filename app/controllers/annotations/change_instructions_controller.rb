class Annotations::ChangeInstructionsController < ApplicationController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = self.name

  def change_instructions
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    render :json => {data: concept.change_instructions}, :status => 200
  end

  def add
    change_instruction = Annotation::ChangeInstruction.create(the_params)
    status = change_instruction.errors.empty? ? 200 : 400
    render :json => {data: "", errors: change_instruction.errors.full_messages}, :status => status
  end

  def update
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.update(the_params)
    status = change_instruction.errors.empty? ? 200 : 400
    render :json => {data: change_instruction.to_h, errors: change_instruction.errors.full_messages}, :status => status
  end

  def delete
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.delete
    render :json => {errors: []}, :status => 200
  end

private

  def the_params
    params.require(:change_instruction).permit(:reference, :description, :semantic, :previous => [], :current => [])
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize IsoConcept
  end

end