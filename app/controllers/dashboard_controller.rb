class DashboardController < ApplicationController

  before_action :authenticate_user!
  
  def index
  	@forms = Form.all()
  end

  def view
  	@dashboard = Dashboard.new
  	@namespaces = UriManagement.get()
  	@id = params[:id]
    @namespace = params[:namespace]
  end

  def database
  	@triples = Dashboard.find(params[:id], params[:namespace])
    render json: @triples
  end

private

  def the_params
    params.require(:dashboard).permit(:id, :namespace)
  end  

end
