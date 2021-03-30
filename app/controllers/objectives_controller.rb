require 'controller_helpers.rb'

class ObjectivesController < ManagedItemsController
  
  before_action :authenticate_and_authorized

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @objective = Objective.find_minimum(protect_from_bad_id(params))
    #@show_path = show_data_objective_path(@objective)
    @close_path = history_objectives_path(:objective => {identifier: @objective.has_identifier.identifier, scope_id: @objective.scope})
  end

private
  
  def the_params
    params.require(:objective).permit(:identifier, :scope_id, :count, :offset)
  end

    # Path for given action
  def path_for(action, object)
    case action
      when :show
        return objective_path(object)
      when :edit
        return ""
      else
        return super(action, object)
    end
  end

  def model_klass
    Objective
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_endpoints_path({objective:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    objectives_path
  end       

end
