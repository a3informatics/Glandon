# Studies Controller

require 'controller_helpers.rb'

class StudiesController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = self.name

  def index

  end

  def index_data
    authorize Form, :view?
    studies = Study.unique
    studies = studies.map{|x| x.reverse_merge!({history_path: history_studies_path({study:{identifier: x[:identifier], scope_id: x[:scope_id]}})})}
    render json: {data: studies}, status: 200
  end

  def update

  end

  def create
    authorize Form, :create?
    study = Study.create(the_params)
    if study.errors.empty?
      render json: {history_url: history_studies_path({study:{identifier: study.scoped_identifier, scope_id: study.has_identifier.has_scope.id}})}, status: 200
    else
      render json: {errors: [study.errors.full_messages]}, status: 422
    end
  end

  def history

  end

  def history_data
    authorize Form, :view?
    results = []
    history_results = Study.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
    current = Study.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    latest = Study.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    results = add_history_paths(Study, history_results, current, latest)
    render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
  end

private

  def the_params
    params.require(:study).permit(:identifier, :label, :name, :protocol_id, :description, :scope_id, :count, :offset)
  end

end