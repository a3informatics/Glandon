class IsoManagedNewsController < ApplicationController
  
  before_action :authenticate_user!
  
  def update
    authorize IsoManagedNew
    #referer = this_params[:referer]
    @referer = request.referer
    managed_item = IsoManagedNew.find(params[:id], this_params[:ns])
    managed_item.update(params[:id], this_params[:ns], this_params)
    redirect_to @referer
  end

  def edit
    authorize IsoManagedNew
    @referer = request.referer
    @managed_item = IsoManagedNew.find(params[:id], params[:ns], false)
    @registration_state = @managed_item.registrationState
    @scoped_identifier = @managed_item.scopedIdentifier
    @current_id = params[:current_id]
    @owner = IsoRegistrationAuthority.owner.shortName == @managed_item.owner
    @history = IsoManagedNew.history(ModelUtility.extractCid(@managed_item.rdf_type), 
      ModelUtility.extractNs(@managed_item.rdf_type), 
      {:identifier => @managed_item.identifier, :scope_id => @managed_item.owner_id})
  end

  private

    def this_params
      params.require(:iso_managed_new).permit(:ns, :changeDescription, :explanatoryComment, :origin)
    end

end
