class BiomedicalConceptsController < ApplicationController
  
  C_CLASS_NAME = "BiomedicalConceptsController"

  before_action :authenticate_user!
  
  def index
    @bcts = BiomedicalConceptTemplate.all
    @bcs = BiomedicalConcept.unique
    @biomedical_concept = BiomedicalConcept.new
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @bcs.each do |item|
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

  def new_template
    uri = params[:uri]
    parts = uri.split('#')
    ns = parts[0]
    id = parts[1]
    @bct = BiomedicalConceptTemplate.find(id, ns)
  end

  def edit
    ns = params[:namespace]
    id = params[:id]
    @bc = BiomedicalConcept.find(id, ns)
  end

  def impact
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    @forms = Form.impact(params)
    @domains = Domain.impact(params)
  end

  def create
    instance = params[:instance]
    @bc = BiomedicalConcept.create(params[:data])
    if @bc.errors.empty?
      render :json => { :instance => instance, :data => @bc.to_edit}, :status => 200
    else
      render :json => { :errors => @bc.errors.full_messages}, :status => 422
    end
  end

  def update
    id = params[:id]
    namespace = params[:namespace]
    instance = params[:instance]
    bc = BiomedicalConcept.find(id, namespace)
    bc.destroy
    @bc = BiomedicalConcept.create(params[:data])
    if @bc.errors.empty?
      render :json => { :instance => instance, :data => @bc.to_edit}, :status => 200
    else
      render :json => { :errors => @bc.errors.full_messages}, :status => 422
    end
  end

  def destroy
    id = params[:id]
    namespace = params[:namespace]
    bc = BiomedicalConcept.find(id, namespace)
    bc.destroy
    redirect_to biomedical_concepts_path
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    @items = @bc.flatten
  end
  
private
  def the_params
    params.require(:biomedical_concept).permit(:data)
  end  
end
