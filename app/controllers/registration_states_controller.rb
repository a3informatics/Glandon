class RegistrationStatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @registrationStates = RegistrationState.all
  end
  
  def new
    @RegistrationState = RegistrationState.new
  end
  
  def create
    @RegistrationState = RegistrationState.create(this_params)
    redirect_to registration_states_path
  end

  def update
    referer = this_params[:referer]
    registrationState = RegistrationState.find(params[:id])
    registrationState.update(params[:id], this_params)
    redirect_to referer
  end

  def edit
    @referer = request.referer
    @registrationState = RegistrationState.find(params[:id])
  end

  def destroy
     @RegistrationState = RegistrationState.find(params[:id])
     @RegistrationState.destroy
     redirect_to registration_states_path
  end

  def show
    redirect_to registration_states_path
  end
  
  private
    def this_params
      params.require(:registration_state).permit(:registrationAuthority, :registrationStatus, :administrativeNote, :effectiveDate, :unresolvedIssue, :administrativeStatus, :previousState, :referer)
    end

end
