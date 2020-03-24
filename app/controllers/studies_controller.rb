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
    studies = studies.map{|x| x.reverse_merge!({history_path: history_study_path({id: x[:id]})})}
    render json: {data: studies}, status: 200
  end

  def history
    @close_path = studies_path
  end

  def history_data

  end

  # def update
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
    render json: {history_url: history_study_path(id: @study.id)}, status: 200
  end

  def history

  end

  def history_data

  end

private

  def the_params
    params.require(:study).permit(:identifier, :label, :name, :protocol_id, :description)
  end

  # def authenticate_and_authorized
  #   authenticate_user!
  #   authorize Form
  # end

end
