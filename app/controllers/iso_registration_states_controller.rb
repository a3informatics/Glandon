class IsoRegistrationStatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize IsoRegistrationState
    @registration_states = IsoRegistrationState.all
  end
  
  def update
    authorize IsoRegistrationState
    referer = request.referer
    registration_state = IsoRegistrationState.find(params[:id])
    registration_state.update(this_params)
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

  def this_params
    params.require(:iso_registration_state).permit(:registrationAuthority, :registrationStatus, :administrativeNote, :unresolvedIssue, :administrativeStatus, :previousState, :referer)
  end

end
