class BiomedicalConceptTemplatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize BiomedicalConceptTemplate
    @bcts = BiomedicalConceptTemplate.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = @bcts
        render json: results
      end
    end
  end
  
  def history
    authorize BiomedicalConceptTemplate
    @identifier = params[:identifier]
    @bct = BiomedicalConceptTemplate.history(params)
    redirect_to biomedical_concept_templates_path if @bct.count == 0
  end

  def show 
    authorize BiomedicalConcept
    @bct = BiomedicalConceptTemplate.find(params[:id], params[:namespace])
    respond_to do |format|
      format.html do
        @items = @bct.get_properties
      end
      format.json do
        @items = @bct.get_properties
        render json: @items
      end
    end
  end

private

  def the_params
    params.require(:bct).permit()
  end  

end