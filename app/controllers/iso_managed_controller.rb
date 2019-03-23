class IsoManagedController < ApplicationController
  
  before_action :authenticate_user!

  C_CLASS_NAME = self.class.to_s
  
  def index
  	authorize IsoManaged
  	@managed_items = IsoManaged.all
  end

  def update
    authorize IsoManaged
    managed_item = IsoManaged.find(params[:id], this_params[:namespace], false)
    managed_item.update(this_params)
    redirect_to this_params[:referer]
  end

  def status
    authorize IsoManaged
    @index_label = this_params[:index_label]
    @index_path = this_params[:index_path]
    @managed_item = IsoManaged.find(params[:id], this_params[:namespace], false)
    @registration_state = @managed_item.registrationState
    @scoped_identifier = @managed_item.scopedIdentifier
    @current_id = this_params[:current_id]
    @owner = @managed_item.owned?
    @referer = request.referer
    @close_path = TypePathManagement.history_url(@managed_item.rdf_type, @managed_item.identifier, @managed_item.scopedIdentifier.namespace.id)
  end

  def changes
    authorize IsoManaged
    klass = TypePathManagement.type_to_class(changes_params[:rdf_type])
    @results = IsoManaged.changes(klass, changes_params, {include: [:label], ignore: [:extensible]})
    @results[:identifier] = changes_params[:identifier]
    @close_path = TypePathManagement.history_url(changes_params[:rdf_type], changes_params[:identifier], changes_params[:scope_id])
  end

  def edit
    authorize IsoManaged
    @managed_item = IsoManaged.find(params[:id], this_params[:namespace], false)
    @index_label = this_params[:index_label]
    @index_path = this_params[:index_path]
    @referer = request.referer
    @close_path = TypePathManagement.history_url(@managed_item.rdf_type, @managed_item.identifier, @managed_item.scopedIdentifier.namespace.id)
  end

  def edit_tags
    authorize IsoManaged, :edit?
    @iso_managed = IsoManaged.find(params[:id], params[:namespace], false)
    @concept_systems = Hash.new
    @concept_systems[:label] = "Root"
    @concept_systems[:children] = Array.new
    cs_set = IsoConceptSystem.all
    cs_set.each do |cs|
      concept_system = IsoConceptSystem.find(cs.id, cs.namespace)
      @concept_systems[:children] << concept_system.to_json
    end
    @referer = request.referer
  end

  def find_by_tag
    authorize IsoManaged, :show?
    items = IsoManaged.find_by_tag(params[:id], params[:namespace])
    respond_to do |format|
      format.json do
        results = Hash.new
        results[:data] = Array.new
        items.each do |item|
          results[:data] << item.to_json
        end
        render json: results
      end
    end
  end

  def add_tag
    authorize IsoManaged, :edit?
    item = IsoManaged.find(params[:id], params[:namespace])
    item.add_tag(params[:tag_id], params[:tag_namespace])
    if item.errors.empty?
      render :json => {}, :status => 200
    else
      render :json => {:errors => item.errors.full_messages}, :status => 422
    end
  end

  def delete_tag
    authorize IsoManaged, :edit?
    item = IsoManaged.find(params[:id], params[:namespace])
    item.delete_tag(params[:tag_id], params[:tag_namespace])
    if item.errors.empty?
      render :json => {}, :status => 200
    else
      render :json => {:errors => item.errors.full_messages}, :status => 422
    end
  end

  def tags
    authorize IsoManaged, :edit?
    item = IsoManaged.find(params[:id], params[:namespace])
    respond_to do |format|
      format.json do
        results = Hash.new
        results[:data] = Array.new
        item.tag_refs.each do |ref|
          results[:data] << IsoConceptSystem::Node.find(ref.id, ref.namespace).to_json
        end
        render json: results
      end
    end
  end

  def branches
    authorize IsoManaged, :branch?
    results = {:data => []}
    items = IsoManaged.branches(params[:id], this_params[:namespace])
    items.each { |x| results[:data] << x.to_json }
    render :json => results, :status => 200
  end

    
  def show 
    authorize IsoManaged
    @item = IsoManaged.find(params[:id], params[:namespace], false)
    render :json => @item.to_json, :status => 200
  end

  def graph
    authorize IsoManaged, :show?
    @item = IsoManaged.find(params[:id], params[:namespace])
    @result = { uri: @item.uri.to_s, rdf_type: @item.rdf_type, label: @item.label }
  end

  def graph_links
    authorize IsoManaged, :show?
    map = {}
    @item = IsoManaged.find(params[:id], params[:namespace])
    results = @item.find_links_from_to()
    results.each do |result|
      result[:uri] = result[:uri].to_s
    end
    render :json => results, :status => 200
  end

  def impact
    authorize IsoManaged, :show?
    @item = IsoManaged.find(params[:id], params[:namespace], false)
    @start_path = impact_start_iso_managed_index_path
  end

  def impact_start
    authorize IsoManaged, :show?
    results = []
    @item = IsoManaged.find(params[:id], params[:namespace], false)
    results << @item.uri.to_s
    render json: results
  end

  def impact_next
    authorize IsoManaged, :show?
    map = {}
    @item = IsoManaged.find(params[:id], params[:namespace], false)
    managed_items = @item.find_links_from_to(from=false)
    managed_items.each do |result|
      result[:uri] = result[:uri].to_s
    end
    render json: { item: @item.to_json, children: managed_items }, status: 200
  end

  def destroy
    authorize IsoManaged
    item = IsoManaged.find(params[:id], this_params[:namespace], false)
    token = Token.obtain(item, current_user)
    if !token.nil?
      item.destroy
      AuditTrail.delete_item_event(current_user, item, "Item deleted.")
      token.release
    else
      flash[:error] = "The item is locked for editing by another user."
    end
    redirect_to request.referer
  end

  def export
    authorize IsoManaged
    uri = UriV3.new(id: params[:id]) # Uses new mechanism
    item = IsoManaged::find(uri.fragment, uri.namespace)
    filename = "#{item.owner_short_name}_#{item.identifier}_#{item.version}.ttl"
    file_path = ExportFileHelpers.save(to_turtle(item.triples), filename)
    render json: {file_path: file_path}, status: 200
  end

private

  def this_params
    params.require(:iso_managed).permit(:namespace, :changeDescription, :explanatoryComment, :origin, :referer, :index_path, :index_label, :current_id)
  end

  def changes_params
    params.require(:iso_managed).permit(:rdf_type, :child_property, :identifier, :scope_id)
  end

end
