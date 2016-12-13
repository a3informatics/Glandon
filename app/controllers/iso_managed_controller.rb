class IsoManagedController < ApplicationController
  
  before_action :authenticate_user!

  C_CLASS_NAME = "IsoManagedController"
  
  def update
    authorize IsoManaged
    managed_item = IsoManaged.find(params[:id], this_params[:namespace])
    managed_item.update(this_params)
    redirect_to this_params[:referer]
  end

  def status
    authorize IsoManaged
    @referer = request.referer
    @managed_item = IsoManaged.find(params[:id], params[:namespace], false)
    @registration_state = @managed_item.registrationState
    @scoped_identifier = @managed_item.scopedIdentifier
    @current_id = params[:current_id]
    @owner = IsoRegistrationAuthority.owner.shortName == @managed_item.owner
  end

  def edit
    authorize IsoManaged
    @managed_item = IsoManaged.find(params[:id], params[:namespace], false)
    @referer = request.referer
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
          uri = UriV2.new({:uri => ref})
          tag = IsoConceptSystem::Node.find(uri.id, uri.namespace)
          results[:data] << tag.to_json
        end
        render json: results
      end
    end
  end

  def show 
    authorize IsoManaged
    @item = IsoManaged.find(params[:id], params[:namespace], false)
    render :json => @item.to_json, :status => 200
  end

  def graph
    authorize IsoManaged, :show?
    @item = IsoManaged.find(params[:id], params[:namespace])
    @result = { uri: @item.uri.to_s, rdf_type: @item.rdf_type }
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
    map = {}
    @item = IsoManaged.find(params[:id], params[:namespace], false)
    managed_items = @item.find_links_from_to(from=false)
    managed_items.each do |result|
      result[:uri] = result[:uri].to_s
    end
    @results = {item: @item.to_json, children: managed_items}
  end

private

  def this_params
    params.require(:iso_managed).permit(:namespace, :changeDescription, :explanatoryComment, :origin, :referer)
  end

end
