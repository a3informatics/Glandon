class CdiscClisController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClisController"

  def show
    authorize CdiscCli
    @cdiscCli = CdiscCli.find(params[:id], params[:namespace])
  end
  
  def changes
    authorize CdiscCli, :view?
    data = CdiscTerm::Utility.cli_changes(UriV3.new({fragment: params[:id], namespace: this_params[:namespace]}))
    @results = data[:results]
    @identifier = data[:identifier]
    @title = data[:title]
    @close_path = request.referer
  end
    
private

  def this_params
    params.require(:cdisc_cli).permit(:namespace)
  end
      
end
