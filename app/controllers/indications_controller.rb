require 'controller_helpers.rb'

class IndicationsController < ManagedItemsController
  
  before_action :authenticate_and_authorized

  include ControllerHelpers

  def index
    super
  end

  def history
    super
  end

  def show
    @item = Indication.find_minimum(protect_from_bad_id(params))
    #@show_path = show_data_indication_path(@item)
    @close_path = history_indications_path(:indication => {identifier: @item.has_identifier.identifier, scope_id: @item.scope})
  end

private
  
  def the_params
    params.require(:indication).permit(:identifier, :scope_id, :count, :offset)
  end

    # Path for given action
  def path_for(action, object)
    case action
      when :show
        return indication_path(object)
      when :edit
        return ""
      else
        return super(action, object)
    end
  end

  def model_klass
    Indication
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_indications_path({indication:{identifier: identifier, scope_id: scope_id}})} 
  end

  def close_path_for
    indications_path
  end       

end
