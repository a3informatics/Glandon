class BiomedicalConceptTemplatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @bcts = BiomedicalConceptTemplate.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @bcts.each do |item|
          results[:data] << item
        end
        render json: results
     end
    end
  end
  
  def history
    @identifier = params[:identifier]
    @bct = BiomedicalConceptTemplate.history(params)
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @bct = BiomedicalConceptTemplate.find(id, namespace)
    @items = @bct.flatten
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:id] = id
        results[:identifier] = @bct.identifier
        results[:label] = @bct.label
        results[:namespace] = namespace
        results[:properties] = []
        @items.each do |property|
          results[:properties] << property
        end
        render json: results
      end
    end
  end

private
  def the_params
    params.require(:bct).permit()
  end  
end
