require 'controller_helpers.rb'

class EndpointsController < ManagedItemsController
  
  before_action :authenticate_and_authorized

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @endpoint = Endpoint.find_minimum(protect_from_bad_id(params))
    #@show_path = show_data_endpoint_path(@endpoint)
    @close_path = history_endpoints_path(:endpoint => {identifier: @endpoint.has_identifier.identifier, scope_id: @endpoint.scope})
  end

private
  
  def the_params
    params.require(:endpoint).permit(:identifier, :scope_id, :count, :offset)
  end

    # Path for given action
  def path_for(action, object)
    case action
      when :show
        return endpoint_path(object)
      when :edit
        return ""
      else
        return super(action, object)
    end
  end

  def model_klass
    Endpoint
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_endpoints_path({endpoint:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    endpoints_path
  end       

end
