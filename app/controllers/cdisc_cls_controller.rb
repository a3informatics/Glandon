class CdiscClsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClsController"

  def show
    authorize CdiscCl
    @cdiscCl = CdiscCl.find(params[:id], params[:namespace])
  end
  
  def changes    
    authorize CdiscCl, :view?
    data = CdiscTerm::Utility.cl_changes(params[:id])
    @results = data[:results]
    @clis = CdiscTerm::Utility.transpose_results(@results)
    @identifier = data[:identifier]
    @title = data[:title]
  end
  
private

  def this_params
    params.require(:cdisc_term).permit(:id, :namespace)
  end
   
end
