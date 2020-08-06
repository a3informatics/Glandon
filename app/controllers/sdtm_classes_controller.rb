require 'controller_helpers.rb'

class SdtmClassesController < ManagedItemsController
  
  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = "SdtmClassesController"

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @sdtm_class = SdtmClass.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_sdtm_class_path(@sdtm_class)
    @close_path = history_sdtm_classes_path(:sdtm_class => {identifier: @sdtm_class.has_identifier.identifier, scope_id: @sdtm_class.scope})
  end

  def show_data
    @sdtm_class = SdtmClass.find_minimum(protect_from_bad_id(params))
    items = @sdtm_class.get_items
    # items = items.each_with_index do |item, index|
    #   item[:order_index] = index + 1
    #   item[:has_coded_value].each do |cv|
    #     cv.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: cv[:reference][:id], unmanaged_concept: {parent_id: cv[:context][:id], context_id: ""}})})
    #   end
    # end
    render json: {data: items}, status: 200
  end
  
  #def history
  #  authorize SdtmModelDomain
  #  @history = SdtmDomainModel.history()
  #end
  
  # def show
  #   @variables = Array.new
  #   @sdtm_model_domain = SdtmModelDomain.find(protect_from_bad_id(params))
  #   @sdtm_model_domain.children.each do |child|
  #     @variables << SdtmModel::Variable.find(child.variable_ref.subject_ref.id, child.variable_ref.subject_ref.namespace)
  #   end
  # end

  # def export_ttl
  #   authorize SdtmModelDomain
  #   @sdtm_model_domain = IsoManaged::find(params[:id], the_params[:namespace])
  #   send_data to_turtle(@sdtm_model_domain.triples), filename: "#{@sdtm_model_domain.owner_short_name}_#{@sdtm_model_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  # end
  
  # def export_json
  #   authorize SdtmModelDomain
  #   @sdtm_model_domain = SdtmModelDomain.find(params[:id], the_params[:namespace])
  #   send_data @sdtm_model_domain.to_json.to_json, filename: "#{@sdtm_model_domain.owner_short_name}_#{@sdtm_model_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  # end

private
  
  def the_params
    params.require(:sdtm_class).permit(:identifier, :scope_id, :offset, :count)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return sdtm_class_path(object)
      when :edit
        return ""
      else
        return ""
    end
  end

  def model_klass
    SdtmClass
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_sdtm_classes_path({sdtm_class:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    sdtm_classes_path
  end         
  
end
