class CdiscBcsController < ApplicationController
  
  C_CLASS_NAME = "CdiscBcsController"

  before_action :authenticate_user!
  
  def index
    @cdiscBcs = CdiscBc.all
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:aaData] = []
        @cdiscBcs.each do |key, bc|
          item = {:id => bc.id, :namespace => bc.namespace, :identifier => bc.identifier, :label => bc.label}
          results[:aaData] << item
        end
        render json: results
      end
    end
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
    @bc = CdiscBc.create(params[:data])
    if @bc.errors.empty?
      render :nothing => true, :status => 200, :content_type => 'text/html'
    else
      render :json => { :errors => @bc.errors.full_messages}, :status => 422
    end
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @cdiscBc = CdiscBc.find(id, namespace)
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:id] = id
        results[:identifier] = @cdiscBc.identifier
        results[:label] = @cdiscBc.label
        results[:namespace] = namespace
        results[:properties] = []
        @cdiscBc.properties.each do |property|
          results[:properties] << property
        end
        render json: results
      end
    end
  end
  
private
  def the_params
    params.require(:cdisc_bc).permit(:identifier, :label, :children[], :data)
  end  
end
