class RegistrationAuthoritiesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @registrationAuthorities = RegistrationAuthority.all
    @owner = RegistrationAuthority.owner
  end
  
  def new
    @namespaces = Namespace.all.map{|key,u|[u.name,u.id]}
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
      params.require(:registration_authority).permit(:namespaceId, :number)
    end

end
