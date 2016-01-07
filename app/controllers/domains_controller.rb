class DomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "FormsController"

  def index
    @domains = Domain.all
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @domains.each do |key, item|
          results[:data] << {:identifier => item.identifier, :label => item.label}
        end
        render json: results
      end
    end
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
