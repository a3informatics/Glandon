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
    results = []
    sdtm_model = SdtmModel.find_minimum(protect_from_bad_id(params))
    items = sdtm_model.managed_children_pagination(the_params)
    items.each do |item|
      sdtm_class = SdtmClass.find_minimum(item.id).to_h
      results << sdtm_class.reverse_merge!({show_path: sdtm_class_path({id: sdtm_class[:id]})})
    end
    render json: {data: results, offset: the_params[:offset].to_i, count: results.count}, status: 200
  end
  
  # def import
  #   authorize SdtmModel
  #   @files = Dir.glob(Rails.root.join("public","upload") + "*.xlsx")
  #   @sdtm_class_model = SdtmModel.new
  #   @next_version = SdtmModel.all.last.next_integer_version
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
        return super(action, object)
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
