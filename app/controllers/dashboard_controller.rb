class DashboardController < ApplicationController

  before_action :authenticate_user!
  
  def index
  	authorize Dashboard
    results = IsoRegistrationState.count()
    @statusCounts = []
    results.each do |key, value|
      @statusCounts << {:y => key, :a => value}
    end
  end

  def view
  	authorize Dashboard
    @dashboard = Dashboard.new
  	@id = params[:id]
    @namespace = params[:namespace]
  end

  def database
  	authorize Dashboard, :view?
    @triples = Dashboard.find(params[:id], params[:namespace])
    render json: @triples
  end

private

  def the_params
    params.require(:dashboard).permit(:id, :namespace)
  end  

end
