class BiomedicalConceptsController < ApplicationController
  
  C_CLASS_NAME = "BiomedicalConceptsController"

  before_action :authenticate_user!
  
  def index
    @bcs = BiomedicalConcept.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @bcs.each do |key, bc|
          item = {:identifier => bc.identifier}
          results[:data] << item
        end
        render json: results
      end
    end
  end
  
  def list
    @bcs = BiomedicalConcept.list
    respond_to do |format|
      format.json do
        results = {}
        results[:aaData] = []
        @bcs.each do |key, bc|
          item = {:id => bc.id, :namespace => bc.namespace, :identifier => bc.identifier, :label => bc.label}
          results[:aaData] << item
        end
        render json: results
      end
    end
  end
  
  def history
    @identifier = params[:identifier]
    @bc = BiomedicalConcept.history(@identifier)
  end

  def new
    @bcts_options = BiomedicalConceptTemplate.all.map{|key,u|[u.identifier,u.id + "|" + u.namespace]}
  end

  def impact
    id = params[:id]
    namespace = params[:namespace]
    @cdiscBc = BiomedicalConcept.find(id, namespace)
    @forms = Form.impact(params)
    @domains = Domain.impact(params)
  end

  def create
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    @bc = BiomedicalConcept.create(params[:data])
    if @bc.errors.empty?
      render :nothing => true, :status => 200, :content_type => 'text/html'
    else
      render :json => { :errors => @bc.errors.full_messages}, :status => 422
    end
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    @items = @bc.flatten
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:id] = id
        results[:identifier] = @bc.identifier
        results[:label] = @bc.label
        results[:namespace] = namespace
        results[:properties] = []
        @items.each do |property|
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
