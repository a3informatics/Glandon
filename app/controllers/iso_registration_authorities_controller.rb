class IsoRegistrationAuthoritiesController < ApplicationController

  before_action :authenticate_and_authorized

  def index
    @registrationAuthorities = IsoRegistrationAuthority.all
    @registrationAuthorities.each {|ra| ra.ra_namespace_objects}
    @owner = IsoRegistrationAuthority.owner
    @namespaces = IsoNamespace.all.map{|u| [u.name, u.id]}
  end

  def new
    @namespaces = IsoNamespace.all.map{|u| [u.name, u.id]}
    @registrationAuthority = IsoRegistrationAuthority.new
  end

  def create
    @registrationAuthority = IsoRegistrationAuthority.create(the_params)
    if @registrationAuthority.errors.empty?
      redirect_to iso_registration_authorities_path
    else
      flash[:error] = @registrationAuthority.errors.full_messages.to_sentence
      redirect_to iso_registration_authorities_path
    end
  end

  def destroy
    begin
      registration_authority = IsoRegistrationAuthority.find(params[:id])
      if registration_authority.not_used?
        registration_authority.delete
        render :json => {}
      else
        render :json => { errors: [ "Registration Authority is in use and cannot be deleted." ] }, status: 422
      end
    rescue => e
      render :json => { errors: [ "Unable to delete Registration Authority." ] }, status: 422
    end
  end

private

  def the_params
    params.require(:iso_registration_authority).permit(:namespace_id, :organization_identifier)
  end

  def model_klass
    IsoRegistrationAuthority
  end

end
