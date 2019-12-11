class IsoRegistrationStatesV2Controller < ApplicationController
  
  before_action :authenticate_and_authorized
    
  # def update
  #   referer = request.referer
  #   @managed_item = IsoManagedV2.find(the_params[:mi_id], the_params[:mi_namespace])
  #   @managed_item.update_status(the_params)
  #   if !@managed_item.errors.empty?
  #     flash[:error] = @managed_item.errors.full_messages.to_sentence
  #   end
  #   redirect_to referer
  # end

  def update
    authorize IsoRegistrationState, :update?
    @managed_item = IsoManagedV2.find_minimum(params[:id])
  byebug
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

  def authenticate_and_authorized
    authenticate_user!
    authorize IsoRegistrationState
  end

end
