require 'controller_helpers.rb'

class SdtmModelsController < ManagedItemsController
  
  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = "SdtmModelsController"

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @sdtm_model = SdtmModel.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_sdtm_model_path(@sdtm_model)
    @close_path = history_sdtm_models_path(:sdtm_model => {identifier: @sdtm_model.has_identifier.identifier, scope_id: @sdtm_model.scope})
  end

  def show_data
    sdtm_model = SdtmModel.find_minimum(protect_from_bad_id(params))
    items = sdtm_model.managed_children_pagination(the_params)
    # items = items.each_with_index do |item, index|
    #   item[:order_index] = index + 1
    #   item[:has_coded_value].each do |cv|
    #     cv.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: cv[:reference][:id], unmanaged_concept: {parent_id: cv[:context][:id], context_id: ""}})})
    #   end
    # end
    render json: {data: items}, status: 200
  end
  
  # def history
  #   authorize SdtmModel
  #   @history = SdtmModel.history()
  # end
  
  # def import
  #   authorize SdtmModel
  #   @files = Dir.glob(Rails.root.join("public","upload") + "*.xlsx")
  #   @sdtm_class_model = SdtmModel.new
  #   @next_version = SdtmModel.all.last.next_version
  # end
  
  # def create
  #   authorize SdtmModel, :import?
  #   hash = SdtmModel.create(the_params)
  #   @sdtm_model = hash[:object]
  #   @job = hash[:job]
  #   if @sdtm_model.errors.empty?
  #     redirect_to backgrounds_path
  #   else
  #     flash[:error] = @sdtm_model.errors.full_messages.to_sentence
  #     redirect_to history_sdtm_models_path
  #   end
  # end
  
  # def show
  #   authorize SdtmModel
  #   @sdtm_model_classes = Array.new
  #   @sdtm_model = SdtmModel.find(params[:id], the_params[:namespace])
  #   @sdtm_model.class_refs.each do |class_ref|
  #     @sdtm_model_classes << IsoManaged.find(class_ref.subject_ref.id, class_ref.subject_ref.namespace, false)
  #   end
  # end

  # def export_ttl
  #   authorize SdtmModel
  #   @sdtm_model = IsoManaged::find(params[:id], the_params[:namespace])
  #   send_data to_turtle(@sdtm_model.triples), filename: "#{@sdtm_model.owner_short_name}_#{@sdtm_model.identifier}.ttl", type: 'application/x-turtle', 
  #   	disposition: 'inline'
  # end
  
  # def export_json
  #   authorize SdtmModel
  #   @sdtm_model = IsoManaged::find(params[:id], the_params[:namespace])
  #   send_data @sdtm_model.to_json.to_json, filename: "#{@sdtm_model.owner_short_name}_#{@sdtm_model.identifier}.json", :type => 'application/json; header=present', 
  #   	disposition: "attachment"
  # end

private
  
  def the_params
    params.require(:sdtm_model).permit(:identifier, :scope_id, :count, :offset)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return sdtm_model_path(object)
      when :edit
        return ""
      else
        return ""
    end
  end

  def model_klass
    SdtmModel
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_sdtm_models_path({sdtm_model:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    sdtm_models_path
  end     

end
