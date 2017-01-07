class CdiscClisController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClisController"

  def show
    authorize CdiscCli
    @cdiscCli = CdiscCli.find(params[:id], params[:namespace])
  end
  
  def changes
    authorize CdiscCli, :view?
    @results = CdiscTerm::Utility.cli_changes(params[:id])
    @identifier = @results.length > 0 ? @results[0][:results][:Identifier][:current] : ""
    @title = @results.length > 0 ? @results[0][:results][:"Preferred Term"][:current] : ""
  end
    
private

    def this_params
      params.require(:cdisc_term).permit(:id, :namespace)
    end
      
end
