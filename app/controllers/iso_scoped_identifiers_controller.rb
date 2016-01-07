class IsoScopedIdentifiersController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @scopedIdentifiers = IsoScopedIdentifier.all
  end
  
  def new
    @namespaces = IsoNamespace.all.map{|key,u|[u.name,u.id]}
    @scopedIdentifier = IsoScopedIdentifier.new
  end
  
  def create
    @scopedIdentifier = IsoScopedIdentifier.create(this_params, ModelUtility.createUid(this_params[:identifier]), this_params[:namespaceId])
    redirect_to iso_scoped_identifiers_path
  end

  def update
  end

  def edit
  end

  def destroy
     @scopedIdentifier = IsoScopedIdentifier.find(params[:id])
     @scopedIdentifier.destroy
     redirect_to iso_scoped_identifiers_path
  end

  def show
    redirect_to iso_scoped_identifier_path
  end
  
  private
    def this_params
      params.require(:iso_scoped_identifier).permit(:identifier, :version, :versionLabel, :itemType, :namespaceId)
    end

end
