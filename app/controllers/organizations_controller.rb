class OrganizationsController < ApplicationController

  before_action :authenticate_user!
  
  def index
    @organizations = Organization.all
  end
  
  def new
    @organization = Organization.new
  end
  
  def create
    @organization = Organization.create(this_params)
    redirect_to organizations_path
  end

  def update
  end

  def edit
  end

  def destroy
     @organization = Organization.find(params[:id])
     @organization.destroy
     redirect_to organizations_path
  end

  def show
    redirect_to organizations_path
  end
  
  private
    def this_params
      params.require(:organization).permit(:name, :shortName)
    end
    
end