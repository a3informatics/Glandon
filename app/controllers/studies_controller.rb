class StudiesController < ApplicationController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = self.name

  def index

  end

  def index_data

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