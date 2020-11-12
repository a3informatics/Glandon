require 'controller_helpers.rb'

class SdtmIgsController < ManagedItemsController
  
  before_action :authenticate_and_authorized

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @sdtm_ig = SdtmIg.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_sdtm_ig_path(@sdtm_ig)
    @close_path = history_sdtm_igs_path(:sdtm_ig => {identifier: @sdtm_ig.has_identifier.identifier, scope_id: @sdtm_ig.scope})
  end

  def show_data
    results = []
    sdtm_ig = SdtmIg.find_minimum(protect_from_bad_id(params))
    items = sdtm_ig.managed_children_pagination(the_params)
    items.each do |item|
      sdtm_ig_domain = SdtmIgDomain.find_minimum(item.id).to_h
      results << sdtm_ig_domain.reverse_merge!({show_path: sdtm_ig_domain_path({id: sdtm_ig_domain[:id]})})
    end
    render json: {data: results, offset: the_params[:offset].to_i, count: results.count}, status: 200
  end
  
  # def import
  #   authorize SdtmIg
  #   @files = Dir.glob(Rails.root.join("public","upload") + "*.xlsx")
  #   @sdtm_ig = SdtmIg.new
  #   @sdtm_models = SdtmModel.all
  #   @next_version = SdtmIg.all.last.next_integer_version
  # end
  
  # def create
  #   authorize SdtmIg, :import?
  #   hash = SdtmIg.create(the_params)
  #   @sdtm_ig = hash[:object]
  #   @job = hash[:job]
  #   if @sdtm_ig.errors.empty?
  #     redirect_to backgrounds_path
  #   else
  #     flash[:error] = @sdtm_ig.errors.full_messages.to_sentence
  #     redirect_to history_sdtm_igs_path
  #   end
  # end
  
private
  
  def the_params
    params.require(:sdtm_ig).permit(:identifier, :scope_id, :count, :offset)
  end

    # Path for given action
  def path_for(action, object)
    case action
      when :show
        return sdtm_ig_path(object)
      when :edit
        return ""
      else
        return ""
    end
  end

  def model_klass
    SdtmIg
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_sdtm_igs_path({sdtm_ig:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    sdtm_igs_path
  end       

end
