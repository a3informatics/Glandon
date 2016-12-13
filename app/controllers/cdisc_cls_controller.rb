class CdiscClsController < ApplicationController
  
  include CdiscTermHelpers

  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClsController"

  def changes    
    authorize CdiscCl, :view?
    @results = cl_changes(params[:id])
    @clis = transpose_results(@results)
  end
  
  def show
    authorize CdiscCl
    @cdiscCl = CdiscCl.find(params[:id], params[:namespace])
  end
  
private

  def this_params
    params.require(:cdisc_term).permit(:id, :namespace)
  end
   
end
