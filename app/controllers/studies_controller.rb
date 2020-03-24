class StudiesController < ApplicationController

  #before_action :authenticate_and_authorized
  before_action :authenticate_user!

  C_CLASS_NAME = self.name

  def index
    authorize Form
    @protocols = Protocol.all
  end

  def index_data
    authorize Form, :view?
    studies = Study.all
    studies = studies.map{|x| x.reverse_merge!({history_path: history_studies_path(study: {identifier: x[:identifier], scope_id: x[:scope_id]})})}
    render json: {data: studies}, status: 200
  end

  def history
    authorize Form, :view?
    @study = Study.latest(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    @identifier = the_params[:identifier]
    @scope_id = the_params[:scope_id]
    @close_path = studies_path
  end

  def history_data
    authorize Form

  end

  def update

  end

  def create
    authorize Form, :create?
    @study = Study.create(the_params)
    if @study.errors.empty?
      flash[:success] = 'Study was successfully created.'
    else
      flash[:error] = @study.errors.full_messages.to_sentence
    end
    render json: {history_url: history_studies_path(study: {identifier: x[:identifier], scope_id: x[:scope_id]}), status: 200
  end

private

  def the_params
    params.require(:study).permit(:identifier, :label, :name, :protocol_id, :description, :scope_id)
  end

  # def authenticate_and_authorized
  #   authenticate_user!
  #   authorize Form
  # end

end
