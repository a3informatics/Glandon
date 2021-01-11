require 'controller_helpers.rb'

class ProtocolsController < ManagedItemsController

  include ControllerHelpers

  before_action :authenticate_user!

  C_CLASS_NAME = self.name

  def index
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
        results = []
        history_results = Protocol.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = Protocol.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = Protocol.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Form, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

  def show
    authorize Form
    protocol = Protocol.find_minimum(protect_from_bad_id(params))
    render json: {data: protocol.name_value}, status: 200
  end

  def from_template
    authorize Form, :edit?
    protocol = Protocol.find_with_properties(protect_from_bad_id(params))
    template = ProtocolTemplate.find_minimum(protect_from_bad_id(id: the_params[:template_id]))
    protocol.from_template(template)
    render json: {data: []}, status: 200
  end

  def objectives
    authorize Form, :show?
    protocol = Protocol.find_minimum(protect_from_bad_id(params))
    # Merge into a single array where selected is a true/false flag (TODO: change the model method)
    result = protocol.objectives[:selected].each { |x| x[:selected] = true } |
             protocol.objectives[:not_selected].each { |x| x[:selected] = false }
    render json: {data: result}, status: 200
  end

  def endpoints
    authorize Form, :show?
    protocol = Protocol.find_minimum(protect_from_bad_id(params))
    # Merge into a single array where selected is a true/false flag (TODO: change the model method)
    result = protocol.endpoints[:selected].each { |x| x[:selected] = true } |
             protocol.endpoints[:not_selected].each { |x| x[:selected] = false }
    render json: {data: result}, status: 200
  end

private

  def the_params
    params.require(:protocols).permit(:identifier, :scope_id, :count, :offset, :template_id)
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
    Protocol
  end

  def history_path_for(identifier, scope_id)
    return {history_path: history_protocols_path({protocols:{identifier: identifier, scope_id: scope_id}})}
  end

  def close_path_for
    protocols_path
  end

end
