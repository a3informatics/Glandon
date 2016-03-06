class DomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "DomainsController"

  def index
    @domains = Domain.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @domains.each do |item|
          results[:data] << item
        end
        render json: results
      end
    end
  end
  
  def history
    @identifier = params[:identifier]
    @domain = Domain.history(@identifier)
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
    @bcs = BiomedicalConcept.all
  end

  def remove 
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @bcs = BiomedicalConcept.all
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
