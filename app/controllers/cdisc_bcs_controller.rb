class CdiscBcsController < ApplicationController
  
  C_CLASS_NAME = "CdiscBcsController"

  before_action :authenticate_user!
  
  def index
    @cdiscBcs = CdiscBc.all
  end
  
  def new
    #@cdiscTerm = CdiscTerm.current
    #@bcts = BiomedicalConceptTemplate.all
    @bcts_options = BiomedicalConceptTemplate.all.map{|key,u|[u.identifier,u.id + "|" + u.namespace]}
  end

  def bct_select
    id = params[:id]
    namespace = params[:namespace]
    @bct = BiomedicalConceptTemplate.find(id, namespace)
    render json: @bct
  end

  def create
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    @bc = CdiscBc.createLocal(params[:data])
    if @bc.errors.count > 0
      render :json => { :errors => @bc.errors.full_messages}, :status => 422
    else
      render :nothing => true, :status => 200, :content_type => 'text/html'
    end
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @cdiscBc = CdiscBc.find(id, namespace)
  end
  
private
  def the_params
    params.require(:cdisc_bc).permit(:identifier, :itemType, :children[], :data)
  end  
end
