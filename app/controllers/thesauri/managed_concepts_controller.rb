class Thesauri::ManagedConceptsController < ApplicationController

  before_action :authenticate_user!

  C_CLASS_NAME = "ThesaurusConceptsController"

  def edit
    authorize Thesaurus
    @thesaurus_concept = Thesaurus::ManagedConcept.find_minimum(params[:id])
    @thesaurus = Thesaurus.find_minimum(the_params[:parent_id])
    @token = get_token(@thesaurus_concept)
    if @token.nil?
      flash[:error] = "The edit lock has timed out."
      redirect_to edit_lock_lost_link(@thesaurus)
    else
      @close_path = edit_lock_lost_link(@thesaurus)
      @tc_identifier_prefix = "#{@thesaurus_concept.identifier}."
    end
  end

  def update
    authorize Thesaurus
    tc = Thesaurus::ManagedConcept.find(params[:id])
    th = Thesaurus.find_minimum(edit_params[:parent_id])
    token = Token.find_token(th, current_user)
    if !token.nil?
      tc = tc.update(edit_params)
      if tc.errors.empty?
        AuditTrail.update_item_event(current_user, tc, "Terminology updated.") if token.refresh == 1
        render :json => {:data => [tc.simple_to_h]}, :status => 200
      else
        errors = []
        tc.errors.each do |name, msg|
          errors << {name: name, status: msg}
        end
        render :json => {:fieldErrors => errors}, :status => 200
      end
    else
      flash[:error] = "The edit lock has timed out."
      render :json => {:data => {}, :link => edit_lock_lost_link(th)}, :status => 422
    end
  end

  def children
    authorize Thesaurus, :edit?
    results = []
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    children = tc.children_pagination({offset: "0", count: "10000"})
    children.each {|c| results << c.reverse_merge!({edit_path: edit_thesauri_unmanaged_concept_path({id: c[:id], unmanaged_concept: {parent_id: tc.id}}),
      delete_path: thesauri_unmanaged_concept_path({id: c[:id], unmanaged_concept: {parent_id: tc.id}})})}
    render :json => { data: results }, :status => 200
  end

  def add_child
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    token = Token.find_token(tc, current_user)
    if !token.nil?
      new_tc = tc.add_child(the_params)
      if new_tc.errors.empty?
        AuditTrail.update_item_event(current_user, tc, "Code list updated.") if token.refresh == 1
        result = new_tc.simple_to_h
        result.reverse_merge!({edit_path: edit_thesauri_unmanaged_concept_path({id: result[:id], unmanaged_concept: {parent_id: tc.id}}),
          delete_path: thesauri_unmanaged_concept_path({id: result[:id], unmanaged_concept: {parent_id: tc.id}})})
        render :json => {data: result}, :status => 200
      else
        render :json => {:errors => new_tc.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The changes were not saved as the edit lock has timed out."]}, :status => 422
    end
  end

  def destroy
    authorize Thesaurus
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    th = Thesaurus.find_minimum(the_params[:parent_id])
    token = Token.find_token(th, current_user)
    if !token.nil?
      tc.destroy
      audit_and_respond(th, tc, token)
    else
      render :json => {:errors => ["The changes were not saved as the edit lock timed out."]}, :status => 422
    end
  end

  # ************************
  # CSV Export
  # ************************

  # def export_csv
  #   authorize CdiscCl, :view?
  #   uri = UriV3.new(id: params[:id]) # Using new mechanism
  #   cl = CdiscCl.find(uri.fragment, uri.namespace)
  #   send_data cl.to_csv, filename: "CDISC_CL_#{cl.identifier}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  # end

  def show
    authorize Thesaurus
    @tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    @tc.synonym_objects
    @tc.preferred_term_objects
    @context_id = the_params[:context_id]
    @can_be_extended = @tc.extensible && !@tc.extended?
    extended_by_uri = @tc.extended_by
    @is_extended = !extended_by_uri.nil?
    @is_extended_path = extended_by_uri.nil? ? "" : thesauri_managed_concept_path({id: extended_by_uri.to_id, managed_concept: {context_id: @context_id}})
    extension_of_uri = @tc.extension_of
    @is_extending = !extension_of_uri.nil?
    @is_extending_path = extension_of_uri.nil? ? "" : thesauri_managed_concept_path({id: extension_of_uri.to_id, managed_concept: {context_id: @context_id}})
  end

  def show_data
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    context_id = the_params[:context_id]
    children = tc.children_pagination(params)
    children.map{|x| x.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: x[:id], unmanaged_concept: {context_id: context_id}})})}
    results = children.map{|x| x.reverse_merge!({delete_path: x[:delete] ? thesauri_unmanaged_concept_path({id: x[:id], unmanaged_concept: {parent_id: tc.id}}) : "" })}
    render json: {data: results, offset: params[:offset].to_i, count: results.count}, status: 200
  end

  def changes
    authorize Thesaurus, :show?
    @tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    @tc.synonym_objects
    @tc.preferred_term_objects
    @version_count = @tc.changes_count(current_user.max_term_display.to_i)
    link_objects = @tc.forward_backward(1, current_user.max_term_display.to_i)
    @links = {}
    link_objects.each {|k,v| @links[k] = v.nil? ? "" : changes_thesauri_managed_concept_path(v.to_id)}
    @close_path = dashboard_index_path
  end

  def changes_data
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    clis = tc.changes(current_user.max_term_display.to_i)
    clis[:items].each {|k,v| v[:changes_path] = changes_thesauri_unmanaged_concept_path(v[:id])}
    render json: {data: clis}
  end

  def differences
    authorize Thesaurus, :show?
    @tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    respond_to do |format|
      format.json do
        render json: {data: @tc.differences}
      end
    end
  end

  def is_extended
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    render json: {data: tc.extended?}
  end

  def is_extension
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    render json: {data: tc.extension?}
  end

  def add_extensions
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    uris = the_params[:extension_ids].map {|x| Uri.new(id: x)}
    tc.add_extensions(uris)
    render json: {data: {}, error: []}
  end

  def destroy_extensions
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    uris = the_params[:extension_ids].map {|x| Uri.new(id: x)}
    tc.delete_extensions(uris)
    render json: {data: {}, error: []}
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

private

  # Set the history path
  def edit_lock_lost_link(thesaurus)
    return history_thesauri_index_path({thesauri: {identifier: thesaurus.scoped_identifier, scope_id: thesaurus.scope.id}})
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

  # def get_thesaurus(thesaurus_concept)
  #   info = IsoManaged.find_managed(thesaurus_concept.id, thesaurus_concept.namespace)
  #   thesaurus = Thesaurus.find(info[:uri].id, info[:uri].namespace)
  #   return thesaurus
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

  def the_params
    params.require(:managed_concept).permit(:parent_id, :identifier, :context_id, :extension_ids => [])
  end

  def edit_params
    params.require(:edit).permit(:notation, :synonym, :definition, :preferred_term, :label, :parent_id)
  end

end
