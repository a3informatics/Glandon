class RegistrationAuthoritiesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @registrationAuthorities = RegistrationAuthority.all
  end
  
  def new
    @registrationAuthority = RegistrationAuthority.new
  end
  
  def create
    @registrationAuthority = RegistrationAuthority.create(ra_params)
    redirect_to registration_authorities_path
  end

  def update
  end

  def edit
  end

  def destroy
     @registrationAuthority = RegistrationAuthority.find(params[:id])
     @registrationAuthority.destroy
     redirect_to registration_authorities_path
  end

  def show
    redirect_to registration_authorities_path
  end
  
  private
    def ra_params
      params.require(:registration_authority).permit(:name, :number, :organization_id)
    end

end
