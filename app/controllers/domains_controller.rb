class DomainsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "FormsController"

  def index
    @domains = Domain.all
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
    @domain = Domain.find(id, namespace)
  end
  
private
  def the_params
    params.require(:domain).permit(:namespace)
  end  
end
