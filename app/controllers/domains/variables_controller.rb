class Domains::VariablesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @variabless = Domain::Variable.all
  end
  
  def new
  end
  
  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    id = params[:id]
    namespace = CGI::unescape(params[:namespace])
    @variable = Domain::Variable.find(id, namespace)
  end
  
private
  def the_params
    params.require(:domain_variable).permit(:namespace)
  end  
end
