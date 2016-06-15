class IsoManagedNewsController < ApplicationController
  
  before_action :authenticate_user!
  
  def update
    authorize IsoManagedNew
    managed_item = IsoManagedNew.find(params[:id], this_params[:namespace])
    managed_item.update(this_params)
    redirect_to this_params[:referer]
  end

  def status
    authorize IsoManagedNew
    @referer = request.referer
    @managed_item = IsoManagedNew.find(params[:id], params[:namespace], false)
    @registration_state = @managed_item.registrationState
    @scoped_identifier = @managed_item.scopedIdentifier
    @current_id = params[:current_id]
    @owner = IsoRegistrationAuthority.owner.shortName == @managed_item.owner
  end

  def edit
    authorize IsoManagedNew
    @managed_item = IsoManagedNew.find(params[:id], params[:namespace], false)
    @referer = request.referer
  end

  private

    def this_params
      params.require(:iso_managed_new).permit(:namespace, :changeDescription, :explanatoryComment, :origin, :referer)
    end

end
