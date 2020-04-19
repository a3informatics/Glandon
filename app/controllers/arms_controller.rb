require 'controller_helpers.rb'

class ArmsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  def timepoints
    authorize Form, :edit?
    arm = Arm.find(protect_from_bad_id(params))
    render json: {data: arm.timepoints}, status: 200
  end

  def add_timepoint
    authorize Form, :edit?
    arm = Arm.find(protect_from_bad_id(params))    
    render json: {data: arm.add_timepoint(the_params)}, status: 200
  end

  def update_timepoints
    authorize Form, :edit?
    arm = Arm.find(protect_from_bad_id(params))    
    arm.update_timepoints(update_params)
    render json: {}, status: 200
  end    

private

  def the_params
    params.require(:arm).permit(:offset, :epoch_id, :tp_data => [])
  end

  def update_params
    params[:arm][:tp_data].map{|k,v| v}
  end

end
