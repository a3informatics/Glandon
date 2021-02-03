class IsoRegistrationStatesV2Controller < ApplicationController
  
  before_action :authenticate_and_authorized
    
  def update
    authorize IsoRegistrationState, :update?
    @managed_item = IsoManagedV2.find_minimum(params[:id])
    @managed_item.has_state.update(multiple_edit: the_params[:multiple_edit])
    if @managed_item.errors.empty?
      render :json => { :data => ""}, :status => 200
    else
      render :json => { :errors => @managed_item.errors.full_messages}, :status => 422
    end
  end


private

  def the_params
    params.require(:iso_registration_state).permit(:registrationAuthority, :registrationStatus, :administrativeNote, :unresolvedIssue, :administrativeStatus, 
      :previousState, :referer, :mi_id, :mi_namespace, :multiple_edit)
  end

  def model_klass
    IsoRegistrationState
  end

end
