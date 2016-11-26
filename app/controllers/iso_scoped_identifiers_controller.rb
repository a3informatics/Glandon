class IsoScopedIdentifiersController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoScopedIdentifiersController"

  def index
    authorize IsoScopedIdentifier
    @scoped_identifiers = IsoScopedIdentifier.all
  end
  
  def new
    authorize IsoScopedIdentifier
    @namespaces = IsoNamespace.all.map{|u| [u.name, u.id]}
    @scoped_identifier = IsoScopedIdentifier.new
  end
  
  def create
    authorize IsoScopedIdentifier
    namespace = IsoNamespace.find(this_params[:namespaceId])
    @scoped_identifier = IsoScopedIdentifier.create(this_params[:identifier], this_params[:version], this_params[:versionLabel], namespace)
    if @scoped_identifier.errors.empty?
      redirect_to iso_scoped_identifiers_path
    else
      flash[:error] = @scoped_identifier.errors.full_messages.to_sentence
      redirect_to new_iso_scoped_identifier_path
    end
  end

  def update
    authorize IsoScopedIdentifier
    @referer = request.referer
    @scoped_identifier = IsoScopedIdentifier.find(params[:id])
    @scoped_identifier.update(this_params)
    ConsoleLogger::log(C_CLASS_NAME, "update", "Latest: #{@scoped_identifier.to_json}")
    if !@scoped_identifier.errors.empty?
      flash[:error] = @scoped_identifier.errors.full_messages.to_sentence
    end
    redirect_to @referer
  end

  def destroy
    authorize IsoScopedIdentifier
    @scoped_identifier = IsoScopedIdentifier.find(params[:id])
    @scoped_identifier.destroy
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
