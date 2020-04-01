class Annotations::ChangeInstructionsController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = self.name

  def create
    authorize IsoConcept, :create?
    change_instruction = Annotation::ChangeInstruction.create
    if change_instruction.errors.empty?
      render json: {edit_path: edit_annotations_change_instruction_path(change_instruction.id)}, status: 200
    else
      render json: {errors: change_instruction.errors.full_messages}, status: 422
    end
  end

  def edit
    authorize IsoConcept, :create?
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    if change_instruction.errors.empty?
      render json: {data: change_instruction.to_h}, status: 200
    else
      render json: {errors: change_instruction.errors.full_messages}, status: 422
    end
  end

  def update
    authorize IsoConcept, :edit?
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.update(the_params)
    status = change_instruction.errors.empty? ? 200 : 400
    render :json => {data: "", errors: change_instruction.errors.full_messages}, :status => status
  end

  def add_references
    authorize IsoConcept, :edit?
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.add_references(the_params)
    if change_instruction.errors.empty?
      render json: {data: ""}, status: 200
    else
      render json: {errors: change_instruction.errors.full_messages}, status: 422
    end
  end

  def remove_reference
    authorize IsoConcept, :edit?
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.remove_reference(the_params[:concept_id])
    status = change_instruction.errors.empty? ? 200 : 400
    render :json => {data: "", errors: change_instruction.errors.full_messages}, :status => status
  end

  def delete
    authorize IsoConcept, :edit?
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.delete
    status = change_instruction.errors.empty? ? 200 : 400
    render :json => {data: "", errors: change_instruction.errors.full_messages}, :status => status
  end

private

  def the_params
    params.require(:change_instruction).permit(:reference, :description, :semantic, :concept_id, :previous => [], :current => [])
  end

end