require 'controller_helpers.rb'

class BiomedicalConceptTemplatesController < ManagedItemsController

  C_CLASS_NAME = "BiomedicalConceptTemplatesController"

  include ControllerHelpers
  
  before_action :authenticate_and_authorized

  def index
    super
  end

  def history
    super
  end
  
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
    params.require(:biomedical_concept_template).permit(:identifier, :scope_id, :offset, :count)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return ""
      when :edit
        return ""
      else
        return ""
    end
  end

  def model_klass
    BiomedicalConceptTemplate
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_biomedical_concept_templates_path({biomedical_concept_template:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    biomedical_concept_templates_path
  end    

end