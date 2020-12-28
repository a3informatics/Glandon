require 'controller_helpers.rb'

class AdamIgDatasetsController < ManagedItemsController
  
  before_action :authenticate_and_authorized

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @adam_ig_dataset = AdamIgDataset.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_adam_ig_dataset_path(@adam_ig_dataset)
    @close_path = history_adam_ig_datasets_path(:adam_ig_dataset => {identifier: @adam_ig_dataset.has_identifier.identifier, scope_id: @adam_ig_dataset.scope})
  end

  def show_data
    adam_ig_dataset = AdamIgDataset.find_minimum(protect_from_bad_id(params))
    items = adam_ig_dataset.get_children
    render json: {data: items}, status: 200
  end

  
  # def show
  #   @adam_ig_dataset = AdamIgDataset.find(params[:id])
  # end

  # def export_ttl
  #   uri = UriV3(id: params[:id])
  #   item = IsoManaged::find(uri.id, uri.namespace)
  #   send_data to_turtle(item.triples), filename: "#{item.owner_short_name}_#{item.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  # end
  
  # def export_json
  #   item = AdamIgDataset.find(params[:id])
  #   send_data item.to_json.to_json, filename: "#{item.owner_short_name}_#{item.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  # end
  
private
  
  def the_params
    params.require(:adam_ig_dataset).permit(:identifier, :scope_id, :count, :offset)
  end

    # Path for given action
  def path_for(action, object)
    case action
      when :show
        return adam_ig_dataset_path(object)
      when :edit
        return ""
      else
        return super(action, object)
    end
  end

  def model_klass
    AdamIgDataset
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_adam_ig_datasets_path({adam_ig_dataset:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    adam_ig_datasets_path
  end

end
