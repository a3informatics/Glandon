class Thesauri::UnmanagedConceptsController < ManagedItemsController
  
  before_action :authenticate_user!

  include DatatablesHelpers

  def changes
    authorize Thesaurus, :show?
    @tc = Thesaurus::UnmanagedConcept.find(protect_from_bad_id(params))
    @tc.synonym_objects
    @tc.preferred_term_objects
    @version_count = @tc.changes_count(current_user.max_term_display.to_i)
    @close_path = request.referer
  end

  # TAKE CARE WITH NEXT ACTION. Commented out as does not appear to be be used
  # def changes_data
  #   authorize Thesaurus, :show?
  #   tc = Thesaurus::UnmanagedConcept.find(protect_from_bad_id(params))
  #   render json: {data: tc.changes(current_user.max_term_display.to_i)}
  # end

  def differences
    authorize Thesaurus, :show?
    tc = Thesaurus::UnmanagedConcept.find(protect_from_bad_id(params))
    render json: {data: tc.differences}
  end

  def update
    authorize Thesaurus
    tc = Thesaurus::UnmanagedConcept.find_children(protect_from_bad_id(params))
    parent = Thesaurus::ManagedConcept.find_minimum(edit_params[:parent_id])
    return true unless check_lock_for_item(parent)
    tc = handle_update_with_clone(tc, edit_params, parent)
    if tc.errors.empty?
      AuditTrail.update_item_event(current_user, parent, "Code list updated.") if @lock.token.refresh == 1
      result = tc.simple_to_h(parent, edit_params[:with_custom_props])
      edit_path = Thesaurus::ManagedConcept.identifier_scheme_flat? ? "" : edit_thesauri_unmanaged_concept_path({id: tc.id, unmanaged_concept: {parent_id: parent.id}})
      delete_path = thesauri_unmanaged_concept_path({id: tc.id, unmanaged_concept: {parent_id: parent.id}})
      result.reverse_merge!({edit_path: edit_path, delete_path: delete_path})
      render :json => {:data => [result]}, :status => 200
    else
      render :json => {:fieldErrors => format_editor_errors(tc.errors)}, :status => 200
    end
  end

  def destroy
    authorize Thesaurus
    tc = Thesaurus::UnmanagedConcept.find(protect_from_bad_id(params))
    parent = Thesaurus::ManagedConcept.find_minimum(the_params[:parent_id])
    return true unless check_lock_for_item(parent)
    tc.delete_or_unlink(parent)
    AuditTrail.update_item_event(current_user, parent, "Code list updated, item #{tc.identifier} deleted.") if @lock.token.refresh == 1
    render :json => {data: []}, :status => 200
  end

  def show
    authorize Thesaurus
    @context_id = the_params[:context_id]
    if !@context_id.blank?
      @ct = Thesaurus.find_minimum(@context_id)
    end
    @tc = Thesaurus::UnmanagedConcept.find(protect_from_bad_id(params))
    @parent = Thesaurus::ManagedConcept.find_minimum(the_params[:parent_id])
    @tc.synonym_objects
    @tc.preferred_term_objects
    @has_children = @tc.children?
    @edit_tags_path = @tc.supporting_edit? ? edit_tags_iso_concept_path(@tc, iso_concept: {context_id: the_params[:context_id], parent_id: the_params[:parent_id]}) : ""
    @close_path = thesauri_managed_concept_path({id: the_params[:parent_id], managed_concept: {context_id: the_params[:context_id]}})
  end

  def show_data
    authorize Thesaurus, :show?
    context_id = the_params[:context_id]
    if !context_id.blank?
      ct = Thesaurus.find_minimum(context_id)
      params[:tags] = ct.is_owned_by_cdisc? ? ct.tag_labels : []
    else
      params[:tags] = []
    end
    tc = Thesaurus::UnmanagedConcept.find(protect_from_bad_id(params))
    children = tc.children_pagination(params)
    results = children.map{|x| x.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: x[:id], unmanaged_concept: {context_id: context_id}})})}
    render json: {data: results, offset: params[:offset], count: results.count}, status: 200
  end

  def synonym_links
    authorize Thesaurus, :show?
    tc = Thesaurus::UnmanagedConcept.find_children(protect_from_bad_id(params))
    results = tc.linked_by_synonym(link_params)
    add_link_paths(results)
    render :json => {data: results}, :status => 200
  end

  def preferred_term_links
    authorize Thesaurus, :show?
    tc = Thesaurus::UnmanagedConcept.find_children(protect_from_bad_id(params))
    results = tc.linked_by_preferred_term(link_params)
    add_link_paths(results)
    render :json => {data: results}, :status => 200
  end

  def change_instruction_links
    authorize Thesaurus, :show?
    tc = Thesaurus::UnmanagedConcept.find_children(protect_from_bad_id(params))
    results = tc.linked_change_instructions
    add_ci_link_paths(results)
    render :json => {data: results}, :status => 200
  end

private

  # Handle update with clone.
  def handle_update_with_clone(tc, params, parent)
    return tc.update_with_clone(edit_params, parent) unless params.key?(:custom_property)
    params = params[:custom_property]
    cp = CustomPropertyValue.find_children(protect_from_bad_id(params))
    cp.update_and_clone(params, parent)
    tc.errors.merge!(cp.errors)
    tc
  end

  def add_link_paths(results)
    results.each do |syn, syn_results|
      syn_results[:references].each do |ref|
        if ref[:child][:identifier].empty?
          ref[:show_path] = thesauri_managed_concept_path({id: ref[:id], unmanaged_concept: link_params})
        else
          uc_params = link_params
          uc_params[:parent_id] = ref[:parent][:id]
          ref[:show_path] = thesauri_unmanaged_concept_path({id: ref[:id], unmanaged_concept: uc_params})
        end
      end
    end
  end

  def add_ci_link_paths(results)
    results.each do |type, content|
      next if type == :description
      content.each do |ref|
        if ref[:child][:identifier].empty?
          ref[:show_path] = thesauri_managed_concept_path({id: ref[:id], unmanaged_concept: link_params})
        else
          uc_params = link_params
          uc_params[:parent_id] = ref[:parent][:id]
          ref[:show_path] = thesauri_unmanaged_concept_path({id: ref[:id], unmanaged_concept: uc_params})
        end
      end
    end
  end

  def edit_lock_lost_link(thesaurus)
    return history_thesauri_index_path(identifier: thesaurus.identifier, scope_id: thesaurus.scope.id)
  end

  def link_params
    return {} if params.dig(:unmanaged_concept, :context_id).nil?
    return {} if params.dig(:unmanaged_concept, :context_id).empty?
    params.require(:unmanaged_concept).permit(:context_id)
  end

  def the_params
    params.require(:unmanaged_concept).permit(:identifier, :parent_id, :context_id)
  end

  def edit_params
    params.require(:edit).permit(:notation, :synonym, :definition, :preferred_term, :label, :parent_id, :with_custom_props, :custom_property => [:id, :value]).to_h
  end

end
