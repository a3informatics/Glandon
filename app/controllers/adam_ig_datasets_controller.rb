class AdamIgDatasetsController < ApplicationController
  
  before_action :authenticate_and_authorized
  
  def show
    @adam_ig_dataset = AdamIgDataset.find(params[:id])
  end

  def export_ttl
    uri = UriV3(id: params[:id])
    item = IsoManaged::find(uri.id, uri.namespace)
    send_data to_turtle(item.triples), filename: "#{item.owner_short_name}_#{item.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    item = AdamIgDataset.find(params[:id])
    send_data item.to_json.to_json, filename: "#{item.owner_short_name}_#{item.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end
  
private
  
  def authenticate_and_authorized
    authenticate_user!
    authorize AdamIgDataset
  end

end
