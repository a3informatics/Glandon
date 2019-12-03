class Annotations::ChangeNotesController < ApplicationController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = self.name

  def update
    change_note = Annotation::ChangeNote.find(params[:id])
    change_note.update(the_params)
    status = change_note.errors.empty? ? 200 : 400
    render :json => {data: change_note.to_h, errors: change_note.errors.full_messages}, :status => status
  end

  def destroy
    change_note = Annotation::ChangeNote.find(params[:id])
    change_note.delete
    render :json => {errors: []}, :status => 200
  end

private

  def the_params
    params.require(:change_note).permit(:reference, :description).merge!(user_reference: current_user.email)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize IsoConcept
  end

end