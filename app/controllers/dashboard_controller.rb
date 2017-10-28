class DashboardController < ApplicationController

  before_action :authenticate_user!
  
  def index
  	authorize Dashboard
  	if current_user.is_only_sys_admin
  		redirect_to admin_dashboard_index_path
  	else
    	results = IsoRegistrationState.count()
    	@statusCounts = []
    	results.each do |key, value|
      	@statusCounts << {:y => key, :a => value}
    	end
    end
  end

  def view
  	authorize Dashboard
    @dashboard = Dashboard.new
  	@id = params[:id]
    @namespace = params[:namespace]
  end

  def database
  	authorize Dashboard
    @triples = Dashboard.find(params[:id], params[:namespace])
    render json: @triples
  end

  def admin
  	authorize Dashboard
  end

private

  def the_params
    params.require(:dashboard).permit(:id, :namespace)
  end  

end
