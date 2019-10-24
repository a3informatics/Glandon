class IsoScopedIdentifiersV2Controller < ApplicationController
  
  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = self.name

  def update
    @referer = request.referer
    @scoped_identifier = IsoScopedIdentifierV2.find(params[:id])
    @scoped_identifier.update(this_params)
    flash[:error] = @scoped_identifier.errors.full_messages.to_sentence if !@scoped_identifier.errors.empty? 
    redirect_to @referer
  end

private

  def this_params
    params.require(:iso_scoped_identifier).permit(:version_label)
  end
  
  def authenticate_and_authorized
    authenticate_user!
    authorize IsoScopedIdentifier
  end

end
