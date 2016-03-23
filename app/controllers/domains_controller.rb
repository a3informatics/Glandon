class DomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "DomainsController"

  def index
    authorize Domain
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
    authorize Domain
    @identifier = params[:identifier]
    @domain = Domain.history(params)
  end

  def update_add
    authorize Domain, :edit?
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @domain.add(the_params)
    redirect_to domain_path(:id => id, :namespace => namespace)
  end

  def update_remove
    authorize Domain, :edit?
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @domain.remove(the_params)
    redirect_to domain_path(:id => id, :namespace => namespace)
  end

  def add
    authorize Domain, :edit?
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @bcs = BiomedicalConcept.all
  end

  def remove 
    authorize Domain, :destroy?
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
    @bcs = BiomedicalConcept.all
  end

  def show 
    authorize Domain
    id = params[:id]
    namespace = params[:namespace]
    @domain = Domain.find(id, namespace)
  end
  
private
  def the_params
    params.require(:domain).permit(:namespace, :bcs => [])
  end  
end
