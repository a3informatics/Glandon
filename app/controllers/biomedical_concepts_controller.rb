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
        results = {:data => []}
        @bcs.each { |x| results[:data] << x.to_json }
        render json: results
      end
    end
  end

  def history
    authorize BiomedicalConcept
    @identifier = the_params[:identifier]
    @bc = BiomedicalConcept.history(the_params)
    redirect_to biomedical_concepts_path if @bc.count == 0
  end

  def new_from_template
    authorize BiomedicalConcept, :new?
    uri = UriV2.new({uri: the_params[:uri]})
    @bct = BiomedicalConceptTemplate.find(uri.id, uri.namespace)
  end

  def create
    authorize BiomedicalConcept
    @bc = BiomedicalConcept.create_simple(the_params)
    if @bc.errors.empty?
      flash[:success] = 'Biomedical Concept was successfully created.'
      AuditTrail.create_item_event(current_user, @bc, "Biomedical Concept created.")
      redirect_to biomedical_concepts_path
    else
      flash[:error] = @bc.errors.full_messages.to_sentence
      redirect_to biomedical_concepts_path
    end
  end

  def edit
    authorize BiomedicalConcept
    @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
    if @bc.new_version?
      json = @bc.to_operation
      new_bc = BiomedicalConcept.create(json)
      @bc = BiomedicalConcept.find(new_bc.id, new_bc.namespace)
    end
    @close_path = history_biomedical_concepts_path(identifier: @bc.identifier, scope_id: @bc.owner_id)
    @token = Token.obtain(@bc, current_user)
    if @token.nil?
      flash[:error] = "The item is locked for editing by another user."
      redirect_to request.referer
    end
  end

  def clone
    authorize BiomedicalConcept
    @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
  end

  def clone_create
    authorize BiomedicalConcept, :create?
    from_bc = BiomedicalConcept.find(the_params[:bc_id], the_params[:bc_namespace])
    @bc = BiomedicalConcept.create_clone(the_params)
    if @bc.errors.empty?
      AuditTrail.create_item_event(current_user, @bc, "BiomedicalConcept cloned from #{from_bc.identifier}.")
      flash[:success] = 'Biomedical Concept was successfully created.'
      redirect_to biomedical_concepts_path
    else
      flash[:error] = @bc.errors.full_messages.to_sentence
      redirect_to clone_biomedical_concept_path(:id => the_params[:bc_id], :namespace => the_params[:bc_namespace])
    end
  end

=begin
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
=end

  def destroy
    authorize BiomedicalConcept
    bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
    token = Token.obtain(bc, current_user)
    if !token.nil?
      bc.destroy
      AuditTrail.delete_item_event(current_user, bc, "Biomedical Concept deleted.")
      token.release
    else
      flash[:error] = "The item is locked for editing by another user."
    end
    redirect_to request.referer
  end

  def show 
    authorize BiomedicalConcept
    @bc = BiomedicalConcept.find(params[:id], the_params[:namespace])
    respond_to do |format|
      format.html do
        @items = @bc.get_properties(true)
        @references = BiomedicalConcept.get_unique_references(@items)
      end
      format.json do
        @items = @bc.get_properties(false)
        render json: @items
      end
    end
  end

  def export_ttl
    authorize BiomedicalConcept
    bc = IsoManaged.find(params[:id], the_params[:namespace])
    send_data to_turtle(@bc.triples), filename: "#{@bc.owner}_#{@bc.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
  def export_json
    authorize BiomedicalConcept
    bc = IsoManaged.find(params[:id], the_params[:namespace])
    send_data @bc.to_api_json, filename: "#{@bc.owner}_#{@bc.identifier}.json", :type => 'application/json; header=present', disposition: "attachment"
  end

  def upgrade
    authorize BiomedicalConcept
    @bc = BiomedicalConcept.create(params)
    @bc.upgrade
    redirect_to history_biomedical_concept_path(:biomedical_concept => { :identifier => @bc.identifier, :scope_id => @bc.owner_id })
  end
  
private

  def the_params
    params.require(:biomedical_concept).permit(:namespace, :uri, :identifier, :label, :scope_id, :bc_id, :bc_namespace, :bct_id, :bct_namespace)
  end  

end
