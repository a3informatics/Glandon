require 'controller_helpers.rb'

class AssessmentsController < ApplicationController

  C_CLASS_NAME = "AssessmentsController"

  include ControllerHelpers

  before_action :authenticate_user!

  def index
    authorize Form
    @assessments = Assessment.unique
    respond_to do |format|
      format.json do
        @assessments = @assessments.map{|x| x.reverse_merge!({history_path: history_assessments_path({protocol_template:{identifier: x[:identifier], scope_id: x[:scope_id]}})})}
        render json: {data: @assessments}, status: 200
      end
      format.html
    end
  end

  def history
    authorize Form
    respond_to do |format|
      format.json do
        results = []
        history_results = Assessment.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = Assessment.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = Assessment.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Form, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
      format.html do
        @assessment = Assessment.latest(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
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
