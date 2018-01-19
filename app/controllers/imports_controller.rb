class ImportsController < ApplicationController
  
  before_action :authenticate_and_authorized

  def index
  end

private
 
  def authenticate_and_authorized
    authenticate_user!
    authorize Import
  end

end
