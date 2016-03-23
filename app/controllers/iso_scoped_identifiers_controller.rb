class IsoScopedIdentifiersController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize IsoScopedIdentifier
    @scopedIdentifiers = IsoScopedIdentifier.all
  end
  
  def new
    authorize IsoScopedIdentifier
    @namespaces = IsoNamespace.all.map{|key,u|[u.name,u.id]}
    @scopedIdentifier = IsoScopedIdentifier.new
  end
  
  def create
    authorize IsoScopedIdentifier
    namespace = IsoNamespace.find(this_params[:namespaceId])
    @scopedIdentifier = IsoScopedIdentifier.create(this_params[:identifier], this_params[:version], this_params[:versionLabel], namespace)
    redirect_to iso_scoped_identifiers_path
  end

  def destroy
    authorize IsoScopedIdentifier
    @scopedIdentifier = IsoScopedIdentifier.find(params[:id])
    @scopedIdentifier.destroy
    redirect_to iso_scoped_identifiers_path
  end

  def show
    authorize IsoScopedIdentifier
    redirect_to iso_scoped_identifier_path
  end
  
  private
    def this_params
      params.require(:iso_scoped_identifier).permit(:identifier, :version, :versionLabel, :itemType, :namespaceId)
    end

end
