class IsoRegistrationStatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize IsoRegistrationState
    @registrationStates = IsoRegistrationState.all
  end
  
  def update
    authorize IsoRegistrationState
    #referer = this_params[:referer]
    registrationState = IsoRegistrationState.find(params[:id])
    registrationState.update(params[:id], this_params)
    #redirect_to referer
  end

  #def edit
  #  authorize IsoRegistrationState
  #  @referer = request.referer
  #  @registrationState = IsoRegistrationState.find(params[:id])
  #end

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
