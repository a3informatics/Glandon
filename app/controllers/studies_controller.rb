class StudiesController < ApplicationController

  before_action :authenticate_and_authorized

  C_CLASS_NAME = self.name

  def index
    @protocols = Protocol.unique
  end

  def index_data

  end

  def history
    @close_path = studies_path
  end

  def history_data

  end

  # def update

  # end

  def create

  end

private

  def the_params
    params.require(:study).permit(:description)
  end

  def authenticate_and_authorized
    authenticate_user!
    authorize Form
  end

end
