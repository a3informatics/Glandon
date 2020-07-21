class BiomedicalConceptTemplatesController < ApplicationController
  
  before_action :authenticate_user!

  def index
    authorize BiomedicalConceptTemplate
    respond_to do |format|
      format.json do
        @bct = BiomedicalConceptTemplate.unique
        @bct = @bct.map{|x| x.reverse_merge!({history_path: history_biomedical_concept_templates_path({biomedical_concept_template: {identifier: x[:identifier], scope_id: x[:scope_id]}})})}
        render json: {data: @bct}, status: 200
      end
      format.html
    end
  end

  def history
    authorize BiomedicalConceptTemplate
    respond_to do |format|
      format.json do
        results = []
        history_results = BiomedicalConceptTemplate.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = BiomedicalConceptTemplate.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = BiomedicalConceptTemplate.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(BiomedicalConceptTemplate, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
      format.html do
        @bc = BiomedicalConceptTemplate.latest(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        @identifier = the_params[:identifier]
        @scope_id = the_params[:scope_id]
        @close_path = biomedical_concept_templates_path
      end
    end
  end
  
  # def list
  #   authorize BiomedicalConceptTemplate
  #   @bcts = BiomedicalConceptTemplate.list
  #   respond_to do |format|
  #     format.json do
  #     	results = []
  #     	@bcts.each { |x| results << x.to_json}
  #       render json: { data: results }
  #     end
  #   end
  # end
  
  # def all
  #   authorize BiomedicalConceptTemplate
  #   @bcts = BiomedicalConceptTemplate.all
  #   respond_to do |format|
  #     format.json do
  #     	results = []
  #     	@bcts.each { |x| results << x.to_json}
  #       render json: { data: results }
  #     end
  #   end
  # end
  
  # def history
  #   authorize BiomedicalConceptTemplate
  #   @identifier = the_params[:identifier] 
  #   @bct = BiomedicalConceptTemplate.history({identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id])})
		# redirect_to biomedical_concept_templates_path if @bct.count == 0
  # end

  # def show 
  #   authorize BiomedicalConcept
  #   @bct = BiomedicalConceptTemplate.find(params[:id], the_params[:namespace])
  #   respond_to do |format|
  #     format.html do
  #       @items = @bct.get_properties
  #       @close_path = history_biomedical_concept_templates_path(:biomedical_concept_template => { identifier: @bct.identifier, scope_id: @bct.scope.id })
  #     end
  #     format.json do
  #       @items = @bct.get_properties
  #       render json: @items
  #     end
  #   end
  # end

private

  def the_params
    params.require(:biomedical_concept_template).permit(:identifier, :scope_id)
  end  

end