class BiomedicalConceptTemplatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize BiomedicalConceptTemplate
    @bcts = BiomedicalConceptTemplate.unique
    respond_to do |format|
      format.html 
      format.json do
        render json: { data: @bcts }
      end
    end
  end
  
  def list
    authorize BiomedicalConceptTemplate
    @bcts = BiomedicalConceptTemplate.list
    respond_to do |format|
      format.json do
      	results = []
      	@bcts.each { |x| results << x.to_json}
        render json: { data: results }
      end
    end
  end
  
  def all
    authorize BiomedicalConceptTemplate
    @bcts = BiomedicalConceptTemplate.all
    respond_to do |format|
      format.json do
      	results = []
      	@bcts.each { |x| results << x.to_json}
        render json: { data: results }
      end
    end
  end
  
  def history
    authorize BiomedicalConceptTemplate
    @identifier = the_params[:identifier] 
    @bct = BiomedicalConceptTemplate.history({identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id])})
		redirect_to biomedical_concept_templates_path if @bct.count == 0
  end

  def show 
    authorize BiomedicalConcept
    @bct = BiomedicalConceptTemplate.find(params[:id], the_params[:namespace])
    respond_to do |format|
      format.html do
        @items = @bct.get_properties
        @close_path = history_biomedical_concept_templates_path(:biomedical_concept_template => { identifier: @bct.identifier, scope_id: @bct.owner_id })
      end
      format.json do
        @items = @bct.get_properties
        render json: @items
      end
    end
  end

private

  def the_params
    params.require(:biomedical_concept_template).permit(:namespace, :identifier, :scope_id)
  end  

end