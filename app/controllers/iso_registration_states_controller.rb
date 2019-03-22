class IsoRegistrationStatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def update
    authorize IsoRegistrationState
    referer = request.referer
    @managed_item = IsoManaged.find(the_params[:mi_id], the_params[:mi_namespace])
    @managed_item.update_status(the_params)
    if !@managed_item.errors.empty?
      flash[:error] = @managed_item.errors.full_messages.to_sentence
    end
    redirect_to referer
  end

  def current
    authorize IsoRegistrationState
    referer = request.referer
    old_id = params[:old_id]
    new_id = params[:new_id]
    if old_id != ""
      IsoRegistrationState.make_not_current(params[:old_id])
    end
    IsoRegistrationState.make_current(params[:new_id])
    redirect_to referer
  end

private

  def the_params
    params.require(:iso_registration_state).permit(:registrationAuthority, :registrationStatus, :administrativeNote, :unresolvedIssue, :administrativeStatus, 
      :previousState, :referer, :mi_id, :mi_namespace)
  end

end
