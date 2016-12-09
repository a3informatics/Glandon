class CdiscClisController < ApplicationController
  
  include CdiscTermHelpers

  before_action :authenticate_user!
  
  C_CLASS_NAME = "CdiscClisController"

  #def index
  #  authorize CdiscCli
  #  @cdiscClis = CdiscCli.all
  #end
  
  def show
    authorize CdiscCli
    @cdiscCli = CdiscCli.find(params[:id], params[:namespace])
  end

  #def compare
  #  authorize CdiscCli, :view?
  #  @results = []
  #  @old_cdisc_term = CdiscTerm.find(params[:oldTermId], params[:oldTermNs], false)
  #  @new_cdisc_term = CdiscTerm.find(params[:newTermId], params[:newTermNs], false)
  #  @old_cli = CdiscCli.find(params[:id], params[:oldTermNs])    
  #  @new_cli = CdiscCli.find(params[:id], params[:newTermNs])
  #  @results << compare_cli(@old_cdisc_term, nil, @old_cli)
  #  @results << compare_cli(@new_cdisc_term, @old_cli, @new_cli)
  #  if !@old_cli.nil?
  #    @title = @old_cli.preferredTerm
  #    @identifier = @old_cli.identifier
  #  else
  #    @title = @new_cli.preferredTerm
  #    @identifier = @new_cli.identifier
  #  end
  #end
  
  def changes
    authorize CdiscCli, :view?
    @results = cli_changes(params[:id])
  end
    
private

    def this_params
      params.require(:cdisc_term).permit(:id, :namespace)
    end
      
end
