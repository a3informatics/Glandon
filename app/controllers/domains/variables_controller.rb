class Domains::VariablesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize Domain::Variable
    @variabless = Domain::Variable.all
  end
  
  def show 
    authorize Domain::Variable
    id = params[:id]
    namespace = CGI::unescape(params[:namespace])
    @variable = Domain::Variable.find(id, namespace)
  end
  
private
  def the_params
    params.require(:domain_variable).permit(:namespace)
  end  
end
