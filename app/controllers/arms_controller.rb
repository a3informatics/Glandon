require 'controller_helpers.rb'

class ArmsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  def timepoints
    authorize Form
    arm = Arm.find(protect_from_bad_id(params))
    render json: {data: arm.timepoints}, status: 200
  end

end
