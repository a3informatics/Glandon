class IsoRegistrationStatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize IsoRegistrationState
    @registrationStates = IsoRegistrationState.all
  end
  
  def update
    authorize IsoRegistrationState
    referer = this_params[:referer]
    registrationState = IsoRegistrationState.find(params[:id])
    registrationState.update(params[:id], this_params)
    redirect_to referer
  end

  def edit
    authorize IsoRegistrationState
    @referer = request.referer
    @registrationState = IsoRegistrationState.find(params[:id])
  end

  private
    def this_params
      params.require(:iso_registration_state).permit(:registrationAuthority, :registrationStatus, :administrativeNote, :effectiveDate, :unresolvedIssue, :administrativeStatus, :previousState, :referer)
    end

end
