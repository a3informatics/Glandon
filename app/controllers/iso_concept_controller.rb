class IsoConceptController < ApplicationController

  before_action :authenticate_user!

  def tags
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    render :json => concept.tags.map{|x| x.pref_label}, :status => 200
  end

  def tags_full
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    results = concept.tags.map{ |x| { id: x.id, label: x.pref_label } }
    render :json => { data: results }, :status => 200
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
    change_instructions = concept.change_instructions
    change_instructions.each do |c|
      next if c[:id] == nil
      results << c.reverse_merge!({edit_path: edit_annotations_change_instruction_path(c[:id]),destroy_path: annotations_change_instruction_path(c[:id])})
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

  def indicators
    authorize IsoConcept, :show?
    concept = IsoConceptV2.find(params[:id])
    results = concept.indicators
    render :json => { data: results }, :status => 200
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
        next if type == :owner
        next if type == :edit
        content.each do |ref|
          if !ref.key?(:child)
            object = Thesaurus::ManagedConcept.find_with_properties(ref[:parent][:id])
            ref[:show_path] = thesauri_managed_concept_path({id: ref[:parent][:id], managed_concept: {context_id: latest_parent(object)}})
          else
            object = Thesaurus::ManagedConcept.find_with_properties(ref[:parent][:id])
            uc_params = link_params
            if uc_params.empty?
              uc_params[:context_id] = latest_parent(object)
            end
            uc_params[:parent_id] = ref[:parent][:id]
            ref[:show_path] = thesauri_unmanaged_concept_path({id: ref[:child][:id], unmanaged_concept: uc_params})
          end
        end
      end
    end
  end

  def latest_parent(object)
    object.current_and_latest_parent.last[:uri].to_id
  rescue => e
    return ""
  end

  def link_params
    return {} if params.dig(:iso_concept, :context_id).nil?
    return {} if params.dig(:iso_concept, :context_id).empty?
    params.require(:iso_concept).permit(:context_id)
  end

  def get_klass(item)
    IsoConceptV2.rdf_type_to_klass(item.find_rdf_type.to_s)
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
