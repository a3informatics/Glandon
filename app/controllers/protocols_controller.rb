require 'controller_helpers.rb'

class ProtocolsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  def show
    authorize Form
    protocol = Protocol.find_minimum(protect_from_bad_id(params))
    render json: {data: protocol.name_value}, status: 200
  end

private

  def the_params
    params.require(:protocol).permit()
  end

  # # Path for given action
  # def path_for(action, object)
  #   case action
  #     when :show
  #       return ""
  #     when :edit
  #       return ""
  #     when :build
  #       return build_study_path(object)
  #     else
  #       return ""
  #   end
  # end

end
