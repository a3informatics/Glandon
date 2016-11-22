class IsoRegistrationAuthoritiesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize IsoRegistrationAuthority
    @registrationAuthorities = IsoRegistrationAuthority.all
    @owner = IsoRegistrationAuthority.owner
  end
  
  def new
    authorize IsoRegistrationAuthority
    @namespaces = IsoNamespace.all.map{|u| [u.name, u.id]}
    @registrationAuthority = IsoRegistrationAuthority.new
  end
  
  def create
    authorize IsoRegistrationAuthority
    @registrationAuthority = IsoRegistrationAuthority.create(ra_params)
    if @registrationAuthority.errors.empty?
      redirect_to iso_registration_authorities_path
    else
      flash[:error] = @registrationAuthority.errors.full_messages.to_sentence
      redirect_to new_registration_authority_path
    end
  end

  def destroy
    authorize IsoRegistrationAuthority
    @registration_authority = IsoRegistrationAuthority.find(params[:id])
    if !@registration_authority.id.empty?
      @registration_authority.destroy
    else
      flash[:error] = "Unable to delete Registration Authority."
    end
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
