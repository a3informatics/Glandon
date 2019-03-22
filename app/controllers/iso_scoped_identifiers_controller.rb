class IsoScopedIdentifiersController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoScopedIdentifiersController"

  def update
    authorize IsoScopedIdentifier
    @referer = request.referer
    @scoped_identifier = IsoScopedIdentifier.find(params[:id])
    @scoped_identifier.update(this_params)
    if !@scoped_identifier.errors.empty?
      flash[:error] = @scoped_identifier.errors.full_messages.to_sentence
    end
    redirect_to @referer
  end

private
    
  def this_params
    params.require(:iso_scoped_identifier).permit(:identifier, :version, :versionLabel, :itemType, :scope_id)
  end

end
