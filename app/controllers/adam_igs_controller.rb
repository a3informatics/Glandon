# ADaM IG Controller
#
# @author Dave Iberson-Hurst
# @since 2.21.0
require 'controller_helpers.rb'

class AdamIgsController < ManagedItemsController
  
  before_action :authenticate_and_authorized

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @adam_ig = AdamIg.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_adam_ig_path(@adam_ig)
    @close_path = history_adam_igs_path(:adam_ig => {identifier: @adam_ig.has_identifier.identifier, scope_id: @adam_ig.scope})
  end

  def show_data
    results = []
    adam_ig = AdamIg.find_minimum(protect_from_bad_id(params))
    items = adam_ig.managed_children_pagination(the_params)
    items.each do |item|
      adam_ig_dataset = AdamIgDataset.find_minimum(item.id).to_h
      results << adam_ig_dataset.reverse_merge!({show_path: adam_ig_dataset_path({id: adam_ig_dataset[:id]})})
    end
    render json: {data: results}, status: 200
  end

  
  # def history
  #   @history = AdamIg.history
  # end
  
  # def show
  #   @adam_ig_tabulations = []
  #   @adam_ig = AdamIg.find(params[:id]) # New id method
  #   @adam_ig.references.each do |ref|
  #     @adam_ig_tabulations << IsoManaged.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
  #   end
  # end
  
  # def export_ttl
  #   @adam_ig = IsoManaged::find(params[:id], the_params[:namespace])
  #   send_data to_turtle(@adam_ig.triples), filename: "#{@adam_ig.owner_short_name}_#{@adam_ig.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  # end
  
  # def export_json
  #   @adam_ig = AdamIg.find(params[:id], the_params[:namespace])
  #   send_data @adam_ig.to_json.to_json, filename: "#{@adam_ig.owner_short_name}_#{@adam_ig.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  # end

private

  def the_params
    params.require(:adam_ig).permit(:identifier, :scope_id, :count, :offset)
  end

    # Path for given action
  def path_for(action, object)
    case action
      when :show
        return adam_ig_path(object)
      when :edit
        return ""
      else
        return ""
    end
  end

  def model_klass
    AdamIg
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_adam_igs_path({adam_ig:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    adam_igs_path
  end

end
