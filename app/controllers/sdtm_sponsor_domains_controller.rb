require 'controller_helpers.rb'

class SdtmSponsorDomainsController < ManagedItemsController

  before_action :authenticate_and_authorized
  
  C_CLASS_NAME = "SdtmSponsorDomainsController"

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(protect_from_bad_id(params))
    @show_path = show_data_sdtm_sponsor_domain_path(@sdtm_sponsor_domain)
    @close_path = history_sdtm_sponsor_domains_path(:sdtm_sponsor_domain => {identifier: @sdtm_sponsor_domain.has_identifier.identifier, scope_id: @sdtm_sponsor_domain.scope})
  end

  def show_data
    sdtm_sponsor_domain = SdtmSponsorDomain.find_minimum(protect_from_bad_id(params))
    items = sdtm_sponsor_domain.get_children
    render json: {data: items}, status: 200
  end
  
private
  
  def the_params
    params.require(:sdtm_sponsor_domain).permit(:identifier, :scope_id, :count, :offset)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return sdtm_sponsor_domain(object)
      when :edit
        return ""
      else
        return ""
    end
  end

  def model_klass
    SdtmSponsorDomain
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_sdtm_sponsor_domains_path({sdtm_sponsor_domain:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    sdtm_sponsor_domains_path
  end        

end
