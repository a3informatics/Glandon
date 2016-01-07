class IsoRegistrationStatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @registrationStates = IsoRegistrationState.all
  end
  
  #def new
  #  @RegistrationState = IsoRegistrationState.new
  #end
  
  #def create
  #  @RegistrationState = IsoRegistrationState.create(this_params)
  #  redirect_to iso_registration_states_path
  #end

  def update
    referer = this_params[:referer]
    registrationState = IsoRegistrationState.find(params[:id])
    registrationState.update(params[:id], this_params)
    redirect_to referer
  end

  def edit
    @referer = request.referer
    @registrationState = IsoRegistrationState.find(params[:id])
  end

  #def destroy
  #   @RegistrationState = IsoRegistrationState.find(params[:id])
  #   @RegistrationState.destroy
  #   redirect_to iso_registration_states_path
  #end

  #def show
  #  redirect_to iso_registration_states_path
  #end
  
  private
    def this_params
      params.require(:iso_registration_state).permit(:registrationAuthority, :registrationStatus, :administrativeNote, :effectiveDate, :unresolvedIssue, :administrativeStatus, :previousState, :referer)
    end

end
