class StudiesController < ApplicationController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = self.name

  def index

  end

  def index_data
    studies = Study.all
    studies = studies.map{|x| x.reverse_merge!({history_path: history_study_path({id: x[:id]})})}
    render json: {data: studies}, status: 200
  end

  def update

  end

  def create

  end

  def history

  end

  def history_data

  end

private

  def the_params
    params.require(:study).permit(:description)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Study
  end

end