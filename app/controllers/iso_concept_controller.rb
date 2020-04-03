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

  def tags_full
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    render :json => concept.tags.map{|x| {id: x.id, label: x.pref_label}}, :status => 200
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
    @concept_system = IsoConceptSystem.root
    @iso_concept = IsoConceptV2.find(protect_from_bad_id(params))
    @concept_klass = get_klass(@iso_concept)
    if @concept_klass == Thesaurus::UnmanagedConcept
      @item = @concept_klass.find(params[:id])
      @parent = Thesaurus::ManagedConcept.find_minimum(the_params[:parent_id])
      @context_id = the_params[:context_id]
    else
      @item = @concept_klass.find_with_properties(params[:id])
    end
    @close_path = request.referer
  end

  def change_instructions
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    results = []
    change_instructions = [concept.change_instructions]
    change_instructions.each do |c|
      next if c[:id] == nil
      results << c.reverse_merge!({edit_path: annotations_change_instruction_path(c[:id]),destroy_path: annotations_change_instruction_path(c[:id])})
    end
    add_ci_show_path(results)
    render :json => {data: results}, :status => 200
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

  def add_ci_show_path(results)
    results.each do |ci|
      ci.each do |type, content|
        next if type == :id
        next if type == :reference
        next if type == :description
        next if type == :edit_path
        next if type == :destroy_path
        content.each do |ref|
          if !ref.key?(:child)
            ref[:show_path] = thesauri_managed_concept_path({id: ref[:parent][:id], managed_concept: link_params})
          else
            uc_params = link_params
            uc_params[:parent_id] = ref[:parent][:id]
            ref[:show_path] = thesauri_unmanaged_concept_path({id: ref[:child][:id], unmanaged_concept: uc_params})
          end
        end
      end
    end
  end
  
  def link_params
    return {} if params.dig(:unmanaged_concept, :context_id).nil?
    return {} if params.dig(:unmanaged_concept, :context_id).empty?
    params.require(:unmanaged_concept).permit(:context_id)
  end

  def get_klass(item)
    IsoConceptV2.rdf_type_to_klass(item.true_type.to_s)
  end

  def this_params
    params.require(:iso_concept).permit(:namespace, :child_property, :rdf_type, :identifier, :concepts => [], :versions => [])
  end

  def cn_params
    params.require(:iso_concept).permit(:reference, :description).merge!(user_reference: current_user.email)
  end

  def the_params
    params.require(:iso_concept).permit(:tag_id, :parent_id, :context_id)
  end

end
