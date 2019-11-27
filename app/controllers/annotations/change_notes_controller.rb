class Annotations::ChangeNotesController < ApplicationController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = self.name

  def update
    change_note = Annotation::ChangeNote.update(this_params)
    render :json => {data: change_note.to_h}, :status => 200
  end

  def destroy
    change_note = Annotation::ChangeNote.find(params[:id])
    change_note.delete
    render :json => {errors: []}, :status => 200
  end

private

  def this_params
    params.require(:change_note).permit(:reference, :description)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize IsoConcept
  end

end
