require 'controller_helpers.rb'

class SdtmIgDomainsController < ManagedItemsController

  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = "SdtmIgDomainsController"

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @sdtm_ig_domain = SdtmIgDomain.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_sdtm_ig_domain_path(@sdtm_ig_domain)
    @close_path = history_sdtm_ig_domains_path(:sdtm_ig_domain => {identifier: @sdtm_ig_domain.has_identifier.identifier, scope_id: @sdtm_ig_domain.scope})
  end

  def show_data
    @sdtm_ig_domain = SdtmIgDomain.find_minimum(protect_from_bad_id(params))
    render json: {data: @sdtm_ig_domain.get_children}, status: 200
  end
  
  # def export_ttl
  #   authorize SdtmIgDomain
  #   @sdtm_ig_domain = IsoManaged::find(params[:id], the_params[:namespace])
  #   send_data to_turtle(@sdtm_ig_domain.triples), filename: "#{@sdtm_ig_domain.owner_short_name}_#{@sdtm_ig_domain.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  # end
  
  # def export_json
  #   authorize SdtmIgDomain
  #   @sdtm_ig_domain = SdtmIgDomain.find(params[:id], the_params[:namespace])
  #   send_data @sdtm_ig_domain.to_json.to_json, filename: "#{@sdtm_ig_domain.owner_short_name}_#{@sdtm_ig_domain.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  # end
  
private
  
  def the_params
    params.require(:sdtm_ig_domain).permit(:identifier, :scope_id, :count, :offset)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return sdtm_ig_domain_path(object)
      when :edit
        return ""
      else
        return super(action, object)
    end
  end

  def model_klass
    SdtmIgDomain
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_sdtm_ig_domains_path({sdtm_ig_domain:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    sdtm_ig_domains_path
  end        

end
