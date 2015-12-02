class IsoNamespacesController < ApplicationController

  before_action :authenticate_user!
  
  def index
    @namespaces = IsoNamespace.all
  end
  
  def new
    @namespace = IsoNamespace.new
  end
  
  def create
    @namespace = IsoNamespace.create(this_params)
    if @namespace.errors.empty?
      redirect_to iso_namespaces_path
    else
      flash[:error] = @namespace.errors.full_messages.to_sentence
      redirect_to new_iso_namespace_path
    end
  end

  def update
  end

  def edit
  end

  def destroy
     @namespace = IsoNamespace.find(params[:id])
     @namespace.destroy
     redirect_to iso_namespaces_path
  end

  def show
    redirect_to namespaces_path
  end
  
  private
    def this_params
      params.require(:iso_namespace).permit(:name, :shortName)
    end
    
end