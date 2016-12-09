class CdiscClsController < ApplicationController
  
  include CdiscTermHelpers

  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClsController"

  #def index
  #  authorize CdiscCl
  #  @cdiscCls = CdiscCl.all
  #end
  
  #def compare
  #  authorize CdiscCl, :view?
  #  data = Array.new
  #  @results = Array.new
  #  @old_term = CdiscTerm.find(params[:oldTermId], params[:oldTermNs], false)
  #  @new_term = CdiscTerm.find(params[:newTermId], params[:newTermNs], false)
  #  @old_cl = CdiscCl.find(params[:id], @old_term.namespace)   
  #  @new_cl = CdiscCl.find(params[:id], @new_term.namespace)
  #  @results << compare_cl(@old_term, nil, @old_cl)
  #  @results <<  compare_cl(@new_term, @oldCl, @newCl)
  #  if @old_cl != nil
  #    @title = @old_cl.label
  #    @identifier = @old_cl.identifier
  #  else
  #    @title = @new_cl.label
  #    @identifier = @new_cl.identifier
  #  end
  #end
  
  def changes    
    authorize CdiscCl, :view?
    @results = cl_changes(params[:id])
    @clis = cli_results(@results)
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
