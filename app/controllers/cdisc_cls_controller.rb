class CdiscClsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClsController"

  def show
    authorize CdiscCl
    @cdiscCl = CdiscCl.find(params[:id], params[:namespace])
  end
  
  def changes    
    authorize CdiscCl, :view?
    @results = CdiscTerm::Utility.cl_changes(params[:id])
    @clis = CdiscTerm::Utility.transpose_results(@results)
    @identifier = @results.length > 0 ? @results[0][:results][:Identifier][:current] : ""
    @title = @results.length > 0 ? @results[0][:results][:"Preferred Term"][:current] : ""
  end
  
private

  def this_params
    params.require(:cdisc_term).permit(:id, :namespace)
  end
   
end
