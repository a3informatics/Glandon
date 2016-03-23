class IsoRegistrationAuthoritiesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize IsoRegistrationAuthority
    @registrationAuthorities = IsoRegistrationAuthority.all
    @owner = IsoRegistrationAuthority.owner
  end
  
  def new
    authorize IsoRegistrationAuthority
    @namespaces = IsoNamespace.all.map{|key,u|[u.name,u.id]}
    @registrationAuthority = IsoRegistrationAuthority.new
  end
  
  def create
    authorize IsoRegistrationAuthority
    @registrationAuthority = IsoRegistrationAuthority.create(ra_params)
    redirect_to iso_registration_authorities_path
  end

  def destroy
    authorize IsoRegistrationAuthority
    @registrationAuthority = IsoRegistrationAuthority.find(params[:id])
    @registrationAuthority.destroy
    redirect_to iso_registration_authorities_path
  end

  def show
    authorize IsoRegistrationAuthority
    redirect_to iso_registration_authorities_path
  end
  
  private
    def ra_params
      params.require(:iso_registration_authority).permit(:namespaceId, :number)
    end

end
