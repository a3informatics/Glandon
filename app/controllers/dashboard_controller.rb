class DashboardController < ApplicationController

  before_action :authenticate_user!
  
  def index
  end

  def view
  	@namespaces = UriManagement.get()
  end

end
