class BiomedicalConceptTemplatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @bcts = BiomedicalConceptTemplate.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @bcts.each do |id|
          item = {:identifier => id}
          results[:data] << item
        end
        render json: results
      end
    end
  end
  
  def history
    @identifier = params[:identifier]
    @bct = BiomedicalConceptTemplate.history(@identifier)
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @bct = BiomedicalConceptTemplate.find(id, namespace)
    respond_to do |format|
      format.html
      format.json do
        render json: @bct
      end
    end
  end

private
  def the_params
    params.require(:bct).permit()
  end  
end
