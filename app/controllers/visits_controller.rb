require 'controller_helpers.rb'

class VisitsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  def add_timepoints
    authorize Form, :edit?
    visit = Visit.find(protect_from_bad_id(params))
    visit.add_timepoints(the_params)
    render json: {}, status: 200
  end

  def remove_timepoints
    authorize Form, :edit?
    visit = Visit.find(protect_from_bad_id(params))
    visit.remove_timepoints(the_params)
    render json: {}, status: 200
  end

private

  def the_params
    params.require(:visit).permit(:timepoints => [])
  end

end
