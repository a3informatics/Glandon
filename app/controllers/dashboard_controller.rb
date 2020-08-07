class DashboardController < ApplicationController

  before_action :authenticate_user!

  def index
    # authenticate_user!
  	authorize Dashboard
  	access = user_access_on_role
  	if (access == :all || access == :admin)
      # do nothing
    elsif access == :term
  		redirect_to thesauri_index_path
    elsif access == :community
      redirect_to cdisc_terms_path
  	else
  		render "error"
    end
  end

  def view
  	authorize Dashboard
    @dashboard = Dashboard.new
  	@id = params[:id]
    @namespace = params[:namespace]
  end

  def database
  	authorize Dashboard
    @triples = Dashboard.find(params[:id], params[:namespace])
    render json: @triples
  end

private

  def the_params
    params.require(:dashboard).permit(:id, :namespace)
  end

  def user_access_on_role
    return :community if current_user.is_only_community?
    return :admin if current_user.is_only_sys_admin
		result = true
		klasses = [Thesaurus, BiomedicalConceptTemplate, BiomedicalConceptInstance, Form, SdtmModel, SdtmClass]
		klasses.each do |klass|
			result = result && policy(klass).index?
		end
		return :all if result
		return :term if policy(Thesaurus).index?
		return :none
	end


end
