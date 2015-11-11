class CdiscBcsController < ApplicationController
  
  C_CLASS_NAME = "CdiscBcsController"

  layout "cdisc_bcs_editor", only: [:new, :edit]

  before_action :authenticate_user!
  
  def index
    @cdiscBcs = CdiscBc.all
  end
  
  def new
    @cdiscTerm = CdiscTerm.current
    #@bcts = BiomedicalConceptTemplate.all
    @bcts_options = BiomedicalConceptTemplate.all.map{|key,u|[u.name,u.id + "|" + u.namespace]}
  end

  def bct_select
    id = params[:id]
    namespace = params[:namespace]
    ConsoleLogger::log(C_CLASS_NAME,"bct_select","*****Entry*****")
    @bct = BiomedicalConceptTemplate.find(id, namespace)
    render json: @bct
    ConsoleLogger::log(C_CLASS_NAME,"bct_select","*****Exit*****")
  end

  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    @cdiscTerm = CdiscTerm.current
    @cdiscBc = CdiscBc.find(params[:id], @cdiscTerm)
  end
  
private
  def the_params
    params.require(:cdisc_bc).permit(:scopedIdentifierId)
  end  
end
