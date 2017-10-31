class DashboardController < ApplicationController

  before_action :authenticate_user!
  
  def index
  	authorize Dashboard
  	access = user_access_on_role
  	if access == :all
    	results = IsoRegistrationState.count()
    	@statusCounts = []
    	results.each do |key, value|
      	@statusCounts << {:y => key, :a => value}
    	end
    elsif access == :term
  		redirect_to history_cdisc_terms_path
  	elsif access == :admin
  		redirect_to admin_dashboard_index_path
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

  def admin
  	authorize Dashboard
  end

private

  def the_params
    params.require(:dashboard).permit(:id, :namespace)
  end  

  def user_access_on_role
		result = true
		klasses = [Thesaurus, BiomedicalConceptTemplate, BiomedicalConcept, Form, SdtmUserDomain]
		klasses.each do |klass|
			result = result && policy(klass).index? 
		end
		return :all if result
		return :term if policy(Thesaurus).index? 
		return :admin if current_user.is_only_sys_admin
		return :none
	end


end
