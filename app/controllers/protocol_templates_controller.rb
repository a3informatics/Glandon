require 'controller_helpers.rb'

class ProtocolTemplatesController < ManagedItemsController

  C_CLASS_NAME = "ProtocolTemplatesController"

  include ControllerHelpers

  before_action :authenticate_user!

  # Missing Controller tests, TODO: FIX 

  def index
    # Authorization needs to use Form as there is no ProtocolTemplate policy, TODO: FIX
    authorize Form
    super
  end

  def history
    authorize Form, :show?
    respond_to do |format|
      format.html do
        super
      end
      format.json do
        # Overriding super because the authorization needs to use Form as there is no ProtocolTemplate policy, TODO: FIX
        results = []
        history_results = ProtocolTemplate.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = ProtocolTemplate.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = ProtocolTemplate.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Form, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

private

  def the_params
    params.require(:protocol_template).permit(:identifier, :scope_id, :offset, :count)
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return ""
      when :edit
        return ""
      else
        return ""
    end
  end

  def model_klass
    ProtocolTemplate
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_protocol_templates_path({protocol_template:{identifier: identifier, scope_id: scope_id}})}
  end

  def close_path_for
    protocol_templates_path
  end

end
