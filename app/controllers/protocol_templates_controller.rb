require 'controller_helpers.rb'

class ProtocolTemplatesController < ApplicationController

  C_CLASS_NAME = "ProtocolTemplatesController"

  include ControllerHelpers

  before_action :authenticate_user!

  def index
    authorize Form
    @pts = ProtocolTemplate.unique
    respond_to do |format|
      format.json do
        @pts = @pts.map{|x| x.reverse_merge!({history_path: "history_path"})}
        render json: {data: @pts}, status: 200
      end
      format.html
    end
  end

  def history
    authorize Form
    respond_to do |format|
      format.json do
        results = []
        history_results = ProtocolTemplate.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = ProtocolTemplate.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = ProtocolTemplate.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Form, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
      format.html do
        @pt = ProtocolTemplate.latest(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        @identifier = the_params[:identifier]
        @scope_id = the_params[:scope_id]
        @close_path = request.referer
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

end
