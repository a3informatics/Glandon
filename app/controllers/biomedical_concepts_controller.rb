class BiomedicalConceptsController < ApplicationController
  
  C_CLASS_NAME = "BiomedicalConceptsController"

  before_action :authenticate_user!
  
  def index
    authorize BiomedicalConcept
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
    authorize BiomedicalConcept
    @bcs = BiomedicalConcept.list
    respond_to do |format|
      format.json do
        results = {}
        results[:aaData] = []
        @bcs.each do |bc|
          item = {:id => bc.id, :namespace => bc.namespace, :identifier => bc.identifier, :label => bc.label}
          results[:aaData] << item
        end
        render json: results
      end
    end
  end
  
  def history
    authorize BiomedicalConcept
    @identifier = params[:identifier]
    @bc = BiomedicalConcept.history(params)
  end

  def new_template
    authorize BiomedicalConcept, :new?
    uri = params[:uri]
    parts = uri.split('#')
    ns = parts[0]
    id = parts[1]
    @bct = BiomedicalConceptTemplate.find(id, ns)
  end

  def edit
    authorize BiomedicalConcept
    ns = params[:namespace]
    id = params[:id]
    @bc = BiomedicalConcept.find(id, ns)
  end

  def clone
    authorize BiomedicalConcept
    ns = params[:namespace]
    id = params[:id]
    @bc = BiomedicalConcept.find(id, ns)
  end

  def impact
    authorize BiomedicalConcept, :view?
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    @forms = Form.impact(params)
    @domains = Domain.impact(params)
  end

  def create
    authorize BiomedicalConcept
    instance = params[:instance]
    @bc = BiomedicalConcept.create(params)
    if @bc.errors.empty?
      render :json => { :instance => instance, :data => @bc.to_edit}, :status => 200
    else
      render :json => { :errors => @bc.errors.full_messages}, :status => 422
    end
  end

  def update
    authorize BiomedicalConcept
    instance = params[:instance]
    @bc = BiomedicalConcept.update(params)
    if @bc.errors.empty?
      render :json => { :instance => instance, :data => @bc.to_edit}, :status => 200
    else
      render :json => { :errors => @bc.errors.full_messages}, :status => 422
    end
  end

  def destroy
    authorize BiomedicalConcept
    id = params[:id]
    namespace = params[:namespace]
    bc = BiomedicalConcept.find(id, namespace)
    bc.destroy
    redirect_to biomedical_concepts_path
  end

  def show 
    authorize BiomedicalConcept
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    @items = @bc.flatten
    @references = @bc.references
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

  def export_ttl
    authorize BiomedicalConcept
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    send_data to_turtle(@bc.triples), filename: "#{@bc.owner}_#{@bc.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize BiomedicalConcept
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    send_data @bc.to_api_json, filename: "#{@bc.owner}_#{@bc.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

  def upgrade
    authorize BiomedicalConcept
    id = params[:id]
    namespace = params[:namespace]
    @bc = BiomedicalConcept.find(id, namespace)
    @bc.upgrade
    redirect_to history_biomedical_concepts_path(:identifier => @bc.identifier, :scope_id => @bc.owner_id)
  end
  
private

  def the_params
    params.require(:biomedical_concept).permit(:data)
  end  

  def to_turtle(triples)
    result = ""
    triples.each do |key, triple_array|
      triple_array.each do |triple|
        if triple[:object].start_with?('http://')
          result += "<#{triple[:subject]}> \t\t\t<#{triple[:predicate]}> \t\t\t<#{triple[:object]}> . \n"
        else
          result += "<#{triple[:subject]}> \t\t\t<#{triple[:predicate]}> \t\t\t\"#{triple[:object]}\" . \n"
        end
      end
    end
    return result
  end

end
