class IsoConceptController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = "IsoConceptController"

  def show
    authorize IsoConcept
    @concept = IsoConcept.find(params[:id], params[:namespace], false)
    render :json => @concept.to_json, :status => 200
  end

  def tags
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    render :json => concept.tags.map{|x| x.pref_label}, :status => 200
  end

  def add_tag
    authorize IsoConcept, :edit?
    item = IsoConceptV2.find(protect_from_bad_id(params))
    item.add_tag(the_params[:tag_id])
    render :json => {}, :status => 200
  end

  def remove_tag
    authorize IsoConcept, :edit?
    item = IsoConceptV2.find(protect_from_bad_id(params))
    item.remove_tag(the_params[:tag_id])
    render :json => {}, :status => 200
  end

  def edit_tags
    authorize IsoConcept, :edit?
    @iso_concept = IsoConceptV2.find(protect_from_bad_id(params))
    @concept_klass = get_klass(@iso_concept) 
    @item = @concept_klass.find_minimum(params[:id])
    @concept_system = IsoConceptSystem.root
    @type = this_params[:rdf_type].to_sym
    @close_path = request.referer
  end

  def change_notes
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    render :json => {data: concept.change_notes.map{|x| x.to_h}}, :status => 200
  end

  def add_change_note
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    change_note = concept.add_change_note(cn_params)
    status = change_note.errors.empty? ? 200 : 400
    render :json => {data: change_note.to_h, errors: change_note.errors.full_messages}, :status => status
  end

  def graph
    authorize IsoConcept, :show?
    concept = IsoConcept.find(params[:id], params[:namespace])
    @result = { uri: concept.uri.to_s, rdf_type: concept.rdf_type, label: concept.label }
  end

  def graph_links
    authorize IsoConcept, :show?
    results = IsoConcept.links_from(params[:id], params[:namespace])
    results += IsoConcept.links_to(params[:id], params[:namespace])
    results.each do |result|
      result[:uri] = result[:uri].to_s
    end
    render :json => results, :status => 200
  end

  def impact
    authorize IsoConcept, :show?
    @item = IsoConcept.find(params[:id], params[:namespace], false)
    @start_path = impact_start_iso_concept_index_path
  end

  def impact_start
    authorize IsoConcept, :show?
    results = []
    @item = IsoConcept.find(params[:id], params[:namespace], false)
    results << @item.uri.to_s
    render json: results
  end

  def impact_next
    authorize IsoConcept, :show?
    managed_items = []
    map = {}
    @item = IsoConcept.find(params[:id], params[:namespace], false)
    concepts = IsoConcept.links_to(params[:id], params[:namespace])
    concepts.each do |concept|
      managed_item = IsoManaged.find_managed(concept[:uri].id, concept[:uri].namespace)
      uri_s = managed_item[:uri].to_s
      managed_items << { uri: uri_s, rdf_type: managed_item[:rdf_type]} if !map.has_key?(uri_s)
      map[uri_s] = true
    end
    render json: { item: @item.to_json, children: managed_items }, status: 200
  rescue => e
    render json: { item: nil, children: [] }, status: 200 # Concept not found exception.
  end

  def changes
    authorize IsoConcept
    items = []
    this_params[:concepts].each do |id|
      uri = UriV3.new(id: id)
      concept = IsoConcept.find(uri.fragment, uri.namespace, false)
      items << TypePathManagement.type_to_class(concept.rdf_type).find(uri.fragment, uri.namespace)
    end
    @results = IsoConcept.changes(items, this_params[:child_property], {include: [:label], ignore: [:extensible]})
    @results[:versions] = this_params[:versions]
    @results[:identifier] = this_params[:identifier]
    @close_path = request.referrer
  end

private

  def get_klass(item)
    klass = IsoConceptV2.rdf_type_to_klass(item.true_type.to_s)
    if klass == Thesaurus::UnmanagedConcept
      return Thesaurus::ManagedConcept
    else
      return klass
    end 
  end

  def this_params
    params.require(:iso_concept).permit(:namespace, :child_property, :rdf_type, :identifier, :concepts => [], :versions => [])
  end

  def cn_params
    params.require(:iso_concept).permit(:reference, :description).merge!(user_reference: current_user.email)
  end

  def the_params
    params.require(:iso_concept).permit(:tag_id)
  end

end
