class DashboardController < ApplicationController

  before_action :authenticate_user!
  
  def index
  	@forms = Form.all()
  end

  def view
  	@namespaces = UriManagement.get()
  end

end
