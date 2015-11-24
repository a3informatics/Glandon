class DomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "FormsController"

  def index
    @domains = Domain.all
  end
  
  def update_add
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @domain.add(the_params)
    redirect_to domain_path(:id => id, :namespace => namespace)
  end

  def update_remove
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @domain.remove(the_params)
    redirect_to domain_path(:id => id, :namespace => namespace)
  end

  def add
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @bcs = CdiscBc.all
  end

  def remove 
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @bcs = CdiscBc.all
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
  end
  
private
  def the_params
    params.require(:domain).permit(:namespace, :bcs => [])
  end  
end
