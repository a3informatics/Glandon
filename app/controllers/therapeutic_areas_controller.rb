require 'controller_helpers.rb'

class TherapeuticAreasController < ManagedItemsController
  
  before_action :authenticate_and_authorized

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @item = TherapeuticArea.find_minimum(protect_from_bad_id(params))
    #@show_path = show_data_therapeutic_area_path(@item)
    @close_path = history_therapeutic_areas_path(:therapeutic_area => {identifier: @item.has_identifier.identifier, scope_id: @item.scope})
  end

private
  
  def the_params
    params.require(:therapeutic_area).permit(:identifier, :scope_id, :count, :offset)
  end

    # Path for given action
  def path_for(action, object)
    case action
      when :show
        return therapeutic_area_path(object)
      when :edit
        return ""
      else
        return super(action, object)
    end
  end

  def model_klass
    TherapeuticArea
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_therapeutic_areas_path({therapeutic_area:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    therapeutic_areas_path
  end       

end
