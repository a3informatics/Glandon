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
    @sdtm_ig = SdtmIg.find_minimum(protect_from_bad_id(params))
    items = @sdtm_ig.get_items
    # items = items.each_with_index do |item, index|
    #   item[:order_index] = index + 1
    #   item[:has_coded_value].each do |cv|
    #     cv.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: cv[:reference][:id], unmanaged_concept: {parent_id: cv[:context][:id], context_id: ""}})})
    #   end
    # end
    render json: {data: items}, status: 200
  end
  
  # def history
  #   authorize SdtmIg
  #   @history = SdtmIg.history
  # end
  
  # def import
  #   authorize SdtmIg
  #   @files = Dir.glob(Rails.root.join("public","upload") + "*.xlsx")
  #   @sdtm_ig = SdtmIg.new
  #   @sdtm_models = SdtmModel.all
  #   @next_version = SdtmIg.all.last.next_version
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
  
  # def show
  #   authorize SdtmIg
  #   @sdtm_ig_domains = Array.new
  #   @sdtm_ig = SdtmIg.find(params[:id], the_params[:namespace])
  #   @sdtm_ig.domain_refs.each do |op_ref|
  #     @sdtm_ig_domains << IsoManaged.find(op_ref.subject_ref.id, op_ref.subject_ref.namespace, false)
  #   end
  # end
  
  # def export_ttl
  #   authorize SdtmIg
  #   @sdtm_ig = IsoManaged::find(params[:id], the_params[:namespace])
  #   send_data to_turtle(@sdtm_ig.triples), filename: "#{@sdtm_ig.owner_short_name}_#{@sdtm_ig.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  # end
  
  # def export_json
  #   authorize SdtmIg
  #   @sdtm_ig = SdtmIg.find(params[:id], the_params[:namespace])
  #   send_data @sdtm_ig.to_json.to_json, filename: "#{@sdtm_ig.owner_short_name}_#{@sdtm_ig.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
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
