require 'controller_helpers.rb'

class TimepointsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  def change_unit
    authorize Form, :edit?
    tp = Timepoint.find(protect_from_bad_id(params))
    tp.set_unit(the_params[:unit])
    render json: {data: []}, status: 200
  end

private

  def the_params
    params.require(:timepoint).permit(:unit)
  end

end
