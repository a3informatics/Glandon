class Annotations::ChangeInstructionsController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = self.name

  def change_instructions
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    change_instructions = concept.linked_change_instructions
    results = change_instructions.map{|x| x.reverse_merge!({edit_path: annotations_change_instruction_path(x[:id])})}
    render :json => {data: results}, :status => 200
  end

  def create
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
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.remove_reference(the_params[:concept_id])
    status = change_instruction.errors.empty? ? 200 : 400
    render :json => {data: "", errors: change_instruction.errors.full_messages}, :status => status
  end

  def delete
    change_instruction = Annotation::ChangeInstruction.find(params[:id])
    change_instruction.delete
    render :json => {errors: []}, :status => 200
  end

private

  def the_params
    params.require(:change_instruction).permit(:reference, :description, :semantic, :concept_id, :previous => [], :current => [])
  end

end