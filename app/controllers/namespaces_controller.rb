class NamespacesController < ApplicationController

  before_action :authenticate_user!
  
  def index
    @namespaces = Namespace.all
  end
  
  def new
    @namespace = Namespace.new
  end
  
  def create
    @namespace = Namespace.create(this_params)
    redirect_to namespaces_path
  end

  def update
  end

  def edit
  end

  def destroy
     @namespace = Namespace.find(params[:id])
     @namespace.destroy
     redirect_to namespaces_path
  end

  def show
    redirect_to namespaces_path
  end
  
  private
    def this_params
      params.require(:namespace).permit(:name, :shortName)
    end
    
end