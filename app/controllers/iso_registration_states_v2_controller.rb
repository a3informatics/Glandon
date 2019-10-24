class IsoRegistrationStatesV2Controller < ApplicationController
  
  before_action :authenticate_and_authorized
    
  def update
    referer = request.referer
    @managed_item = IsoManagedV2.find(params[id])
    @managed_item.update_status(the_params)
    if !@managed_item.errors.empty?
      flash[:error] = @managed_item.errors.full_messages.to_sentence
    end
    redirect_to referer
  end

  def current
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

  def authenticate_and_authorized
    authenticate_user!
    authorize IsoRegistrationState
  end

end
