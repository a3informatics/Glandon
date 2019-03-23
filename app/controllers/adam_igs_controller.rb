# ADaM IG Controller
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class AdamIgsController < ApplicationController
  
  before_action :authenticate_and_authorized
  
  def history
    @history = AdamIg.history
  end
  
  def show
    @adam_ig_tabulations = []
    @adam_ig = AdamIg.find(params[:id]) # New id method
    @adam_ig.references.each do |ref|
      @adam_ig_tabulations << IsoManaged.find(ref.subject_ref.id, ref.subject_ref.namespace, false)
    end
  end
  
  def export_ttl
    @adam_ig = IsoManaged::find(params[:id], the_params[:namespace])
    send_data to_turtle(@adam_ig.triples), filename: "#{@adam_ig.owner_short_name}_#{@adam_ig.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    @adam_ig = AdamIg.find(params[:id], the_params[:namespace])
    send_data @adam_ig.to_json.to_json, filename: "#{@adam_ig.owner_short_name}_#{@adam_ig.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

private
  
  def authenticate_and_authorized
    authenticate_user!
    authorize AdamIg
  end

end
