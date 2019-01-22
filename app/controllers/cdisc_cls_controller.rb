class CdiscClsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClsController"

  def show
    authorize CdiscCl
    @cdiscCl = CdiscCl.find(params[:id], params[:namespace])
  end
  
  def changes    
    authorize CdiscCl, :view?
    version = get_version
    data = CdiscTerm::Utility.cl_changes(UriV3.new({fragment: params[:id], namespace: this_params[:namespace]}))
    @results = data[:results]
    @id = params[:id]
    @namespace = this_params[:namespace]
    @trimmed_results = CdiscTerm::Utility.trim_results(@results, version, current_user.max_term_display.to_i)
    @previous_version = CdiscTerm::Utility.previous_version(@results, @trimmed_results.first[:version])
    @next_version = CdiscTerm::Utility.next_version(@results, @trimmed_results.first[:version], 
    	current_user.max_term_display.to_i, @results.length)
    @clis = CdiscTerm::Utility.transpose_results(@trimmed_results)
    @identifier = data[:identifier]
    @title = data[:title]
  end
  
private

  def this_params
    params.require(:cdisc_cl).permit(:namespace, :version)
  end
  
  def get_version
  	return nil if params[:cdisc_cl].blank? 
    return nil if !this_params.key?(:version)
  	return this_params[:version].to_i
  end

end
