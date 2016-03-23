class IsoNamespacesController < ApplicationController

  before_action :authenticate_user!
  
  def index
    authorize IsoNamespace
    @namespaces = IsoNamespace.all
  end
  
  def new
    authorize IsoNamespace
    @namespace = IsoNamespace.new
  end
  
  def create
    authorize IsoNamespace
    @namespace = IsoNamespace.create(this_params)
    if @namespace.errors.empty?
      redirect_to iso_namespaces_path
    else
      flash[:error] = @namespace.errors.full_messages.to_sentence
      redirect_to new_iso_namespace_path
    end
  end

  def destroy
    authorize IsoNamespace
    @namespace = IsoNamespace.find(params[:id])
    @namespace.destroy
    redirect_to iso_namespaces_path
  end

  def show
    authorize IsoNamespace
    redirect_to namespaces_path
  end
  
  private
    def this_params
      params.require(:iso_namespace).permit(:name, :shortName)
    end
    
end