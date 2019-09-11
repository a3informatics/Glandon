class Thesauri::UnmanagedConceptsController < ApplicationController

  before_action :authenticate_user!

  def changes
    authorize Thesaurus, :view?
    @tc = Thesaurus::UnmanagedConcept.find(params[:id])
    @tc.synonym_objects
    @tc.preferred_term_objects
    respond_to do |format|
      format.html
        @version_count = @tc.changes_count(current_user.max_term_display.to_i)
        @close_path = request.referer
      format.json do
        clis = @tc.changes(current_user.max_term_display.to_i)
        render json: {data: clis}
      end
    end
  end

  def differences
    authorize Thesaurus, :view?
    @tc = Thesaurus::UnmanagedConcept.find(params[:id])
    respond_to do |format|
      format.json do
        render json: {data: @tc.differences}
      end
    end
  end

  # Will be required for Hierarchical terminologies
  # def edit
  #   authorize ThesaurusConcept
  #   @thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace], false)
  #   thesaurus = get_thesaurus(@thesaurus_concept)
  #   @token = Token.find_token(thesaurus, current_user)
  #   @close_path = edit_lock_lost_link(thesaurus)
  #   @referer_path = get_parent_link(@thesaurus_concept)
  #   @tc_identifier_prefix = "#{@thesaurus_concept.identifier}."
  #   if @token.nil?
  #     flash[:error] = "The edit lock has timed out."
  #     redirect_to edit_lock_lost_link(thesaurus)
  #   end
  # end

  def update
    authorize Thesaurus
    tc = Thesaurus::UnmanagedConcept.find_children(params[:id])
    parent = Thesaurus::ManagedConcept.find_minimum(edit_params[:parent_id])
    #token = Token.find_token(parent, current_user)
    #if !token.nil?
      tc = tc.update(edit_params)
      if tc.errors.empty?
        #AuditTrail.update_item_event(current_user, parent, "Code list updated.") if token.refresh == 1
        render :json => {:data => [tc.simple_to_h]}, :status => 200
      else
        errors = []
        tc.errors.each do |name, msg|
          errors << {name: name, status: msg}
        end
        render :json => {:fieldErrors => errors}, :status => 200
      end
    #else
    #  flash[:error] = "The edit lock has timed out."
    #  render :json => {:data => {}, :link => edit_lock_lost_link(tc)}, :status => 422
    #end
  end

  # Will be required for Hierarchical terminologies
  # def children
  #   authorize Thesaurus, :edit?
  #   results = []
  #   thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace])
  #   thesaurus_concept.children.each do |child|
  #     results << child.to_json
  #   end
  #   render :json => { data: results }, :status => 200
  # end

  # Will be required for Hierarchical terminologies
  # def add_child
  #   authorize ThesaurusConcept, :create?
  #   parent_thesaurus_concept = ThesaurusConcept.find(params[:id], params[:namespace], false)
  #   thesaurus = get_thesaurus(parent_thesaurus_concept)
  #   token = Token.find_token(thesaurus, current_user)
  #   if !token.nil?
  #     thesaurus_concept = parent_thesaurus_concept.add_child(the_params)
  #     audit_and_respond(thesaurus, thesaurus_concept, token)
  #   else
  #     render :json => {:errors => ["The changes were not saved as the edit lock timed out."]}, :status => 422
  #   end
  # end

  def destroy
    authorize Thesaurus
    tc = Thesaurus::UnmanagedConcept.find(params[:id])
    parent = Thesaurus::ManagedConcept.find_minimum(the_params[:parent_id])
    # token = Token.find_token(thesaurus, current_user)
    # if !token.nil?
      tc.delete
      if tc.errors.empty?
  #     AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated.") if token.refresh == 1
        render :json => {:data => []}, :status => 200
      else
        render :json => {:errors => tc.errors.full_messages}, :status => 422
      end
    #else
    #  render :json => {:errors => ["The changes were not saved as the edit lock timed out."]}, :status => 422
    #end
  end

  def show
    authorize Thesaurus
    @tc = Thesaurus::UnmanagedConcept.find(params[:id])
    @tc.synonym_objects
    @tc.preferred_term_objects
    @context_id = the_params[:context_id]
    @has_children = @tc.children?
    respond_to do |format|
      format.html
      format.json do
        children = @tc.children_pagination(params)
        results = children.map{|x| x.to_h.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: x, unmanaged_concept: {context_id: @context_id}})})}
        render json: {data: results, offset: params[:offset], count: results.count}, status: 200
      end
    end
  end

  # def cross_reference_start
  # 	authorize ThesaurusConcept, :show?
  # 	results = []
  # 	@direction = the_params[:direction].to_sym
  #   refs = ThesaurusConcept.cross_references(params[:id], the_params[:namespace], @direction)
  #   refs.each { |x| results << x[:uri].to_s }
  #   render json: results
  # end

  # def cross_reference_details
  # 	authorize ThesaurusConcept, :show?
  # 	results = []
  # 	direction = the_params[:direction].to_sym
  #   item = ThesaurusConcept.find(params[:id], the_params[:namespace])
  #   item.set_parent
  #   item.parentIdentifier = item.identifier if item.parentIdentifier.empty?
  #   item.cross_reference_details(direction).each do |detail|
  #   	cr_items = []
  #   	detail[:cross_references].each do |uri|
  #   		cr_items << ThesaurusConcept.find(uri.id, uri.namespace).to_json
  #   	end
  #   	results << { item: item.to_json, comments: detail[:comments], cross_references: cr_items }
  #   end
  #   render json: results
  # end

  def synonym_links
    authorize Thesaurus, :view?
    tc = Thesaurus::UnmanagedConcept.find_children(params[:id])
    results = tc.linked_by_synonym(link_params)
    add_link_paths(results)
    render :json => {:data => results}, :status => 200
  end

  def preferred_term_links
    authorize Thesaurus, :view?
    tc = Thesaurus::UnmanagedConcept.find_children(params[:id])
    results = tc.linked_by_preferred_term(link_params)
    add_link_paths(results)
    render :json => {:data => results}, :status => 200
  end

  def change_instruction_links
    authorize Thesaurus, :view?
    tc = Thesaurus::UnmanagedConcept.find_children(params[:id])
    results = tc.linked_change_instructions
    add_ci_link_paths(results)
    render :json => {:data => results}, :status => 200
  end

private

  def add_link_paths(results)
    results.each do |syn, syn_results|
      syn_results[:references].each do |ref|
        if ref[:child][:identifier].empty?
          ref[:show_path] = thesauri_managed_concept_path({id: ref[:id], unmanaged_concept: link_params})
        else
          ref[:show_path] = thesauri_unmanaged_concept_path({id: ref[:id], unmanaged_concept: link_params})
        end
      end
    end
  end

  def add_ci_link_paths(results)
    results.each do |type, content|
      next if type == :description
      content.each do |ref|
        if ref[:child][:identifier].empty?
          ref[:show_path] = thesauri_managed_concept_path(ref[:id])
        else
          ref[:show_path] = thesauri_unmanaged_concept_path(ref[:id])
        end
      end
    end
  end

  def edit_lock_lost_link(thesaurus)
    return history_thesauri_index_path(identifier: thesaurus.identifier, scope_id: thesaurus.scope.id)
  end

  # def audit_and_respond(thesaurus, thesaurus_concept, token)
  #   if thesaurus_concept.errors.empty?
  #     AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated.") if token.refresh == 1
  #     results = []
  #     results << thesaurus_concept.to_json
  #     render :json => {:data => results}, :status => 200
  #   else
  #     render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
  #   end
  # end

  # def get_parent_link(thesaurus_concept)
  #   link = ""
  #   info = IsoConcept.find_parent(thesaurus_concept.uri)
  #   if !info.nil?
  #     if info[:rdf_type] == Thesaurus::C_RDF_TYPE_URI.to_s
  #       link = edit_thesauri_path(id: info[:uri].id, namespace: info[:uri].namespace)
  #     else
  #       link = edit_thesaurus_concept_path(id: info[:uri].id, namespace: info[:uri].namespace)
  #     end
  #   end
  #   return link
  # end

  def link_params
    return {} if params.dig(:unmanaged_concept, :context_id).nil?
    return {} if params.dig(:unmanaged_concept, :context_id).empty?
    params.require(:unmanaged_concept).permit(:context_id)
  end

  def the_params
    params.require(:unmanaged_concept).permit(:identifier, :parent_id, :context_id)
  end

  def edit_params
    params.require(:edit).permit(:notation, :synonym, :definition, :preferred_term, :label, :parent_id)
  end

end
