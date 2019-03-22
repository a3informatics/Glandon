class IsoScopedIdentifiersController < ApplicationController
  
  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = self.name

  def update
    @referer = request.referer
    @scoped_identifier = IsoScopedIdentifier.find(params[:id])
    @scoped_identifier.update(this_params)
    flash[:error] = @scoped_identifier.errors.full_messages.to_sentence if !@scoped_identifier.errors.empty? 
    redirect_to @referer
  end

private

  def this_params
    params.require(:iso_scoped_identifier).permit(:identifier, :version, :versionLabel, :itemType, :scope_id)
  end
  
  def authenticate_and_authorized
    authenticate_user!
    authorize IsoScopedIdentifier
  end

end
