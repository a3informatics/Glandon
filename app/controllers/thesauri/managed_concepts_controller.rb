class Thesauri::ManagedConceptsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  C_CLASS_NAME = "ThesaurusConceptsController"

  def index
    authorize Thesaurus
    @tcs = Thesaurus::ManagedConcept.unique
  end

  def history
    authorize Thesaurus
    respond_to do |format|
      format.html do
        # @todo This is a bit evil but short term solution. Think fo a more elgant fix.
        results = Thesaurus::ManagedConcept.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
          @thesauri_id = results.first.to_id
          @thesaurus = Thesaurus.find_minimum(@thesauri_id)
          @identifier = the_params[:identifier]
          @scope_id = the_params[:scope_id]
      end
      format.json do
        results = []
        history_results = Thesaurus::ManagedConcept.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = Thesaurus::ManagedConcept.current(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Thesaurus::ManagedConcept, history_results, current)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

  def edit
    authorize Thesaurus
    @thesaurus_concept = Thesaurus::ManagedConcept.find_minimum(params[:id])
    @thesaurus_concept.synonyms_and_preferred_terms
    @thesaurus = Thesaurus.find_minimum(the_params[:parent_id])
    @token = get_token(@thesaurus_concept)
    if @token.nil?
      flash[:error] = "The edit lock has timed out."
      redirect_to edit_lock_lost_link(@thesaurus)
    elsif @thesaurus_concept.subset?
      flash[:error] = "You cannot directly edit the children of a subset."
      redirect_to edit_lock_lost_link(@thesaurus)
    else
      @close_path = edit_lock_lost_link(@thesaurus)
      @tc_identifier_prefix = "#{@thesaurus_concept.identifier}."
    end
  end

  def update
    authorize Thesaurus
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    tc.synonyms_and_preferred_terms
    ct = Thesaurus.find_minimum(edit_params[:parent_id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      tc = tc.update(edit_params)
      if tc.errors.empty?
        AuditTrail.update_item_event(current_user, tc, "Terminology updated.") if token.refresh == 1
        result = tc.simple_to_h
        result.reverse_merge!({edit_path: edit_thesauri_managed_concept_path({id: tc.id, managed_concept: {parent_id: ct.id}}), delete_path: thesauri_managed_concept_path(tc)})
        render :json => {:data => [result]}, :status => 200
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

  def update_properties
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    tc.synonyms_and_preferred_terms
    token = Token.find_token(tc, current_user)
    if !token.nil?
      tc = tc.update(edit_params)
      if tc.errors.empty?
        AuditTrail.update_item_event(current_user, tc, "Managed Concept updated.") if token.refresh == 1
        redirect_to request.referrer
      else
        redirect_to request.referrer
        errors = []
        tc.errors.each do |name, msg|
          flash[:error] = msg
        end
      end
    else
      redirect_to thesauri_managed_concept_path(id: tc.subsets_links.to_id, managed_concept: {context_id: params[:context_id]})
      flash[:error] = "The edit lock has timed out."
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
      tc.delete
      audit_and_respond(th, tc, token)
    else
      render :json => {:errors => ["The changes were not saved as the edit lock timed out."]}, :status => 422
    end
  end

  def export_csv
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_full(params[:id])
    send_data tc.to_csv, filename: "CDISC_CL_#{tc.scoped_identifier}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

  def show
    authorize Thesaurus
    @context_id = the_params[:context_id]
    @ct = Thesaurus.find_minimum(@context_id)
    @tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    @tc.synonym_objects
    @tc.preferred_term_objects
    # @context_id = the_params[:context_id]
    # if !@tc.extended_by.nil?
    #   results = Thesaurus.history_uris(identifier: @ct.has_identifier.identifier, scope: IsoNamespace.find(@ct.scope.id))
    #   thesaurus = Thesaurus.find_minimum(results.first)
    #   @reference_ct_id = thesaurus.uri.to_id
    # end
    @can_be_extended = @tc.extensible && !@tc.extended?
    extended_by_uri = @tc.extended_by
    @is_extended = !extended_by_uri.nil?
    #@is_extended_path = extended_by_uri.nil? ? "" : thesauri_managed_concept_path({id: extended_by_uri.to_id, managed_concept: {context_id: @context_id, reference_ct_id: @reference_ct_id}})
    @is_extended_path = extended_by_uri.nil? ? "" : thesauri_managed_concept_path({id: extended_by_uri.to_id, managed_concept: {context_id: @context_id}})
    extension_of_uri = @tc.extension_of
    @is_extending = !extension_of_uri.nil?
    #@is_extending_path = extension_of_uri.nil? ? "" : thesauri_managed_concept_path({id: extension_of_uri.to_id, managed_concept: {context_id: @context_id, reference_ct_id: @reference_ct_id}})
    @is_extending_path = extension_of_uri.nil? ? "" : thesauri_managed_concept_path({id: extension_of_uri.to_id, managed_concept: {context_id: @context_id}})
    @close_path = thesauri_path(@ct)
  end

  def show_data
    authorize Thesaurus, :show?
    context_id = the_params[:context_id]
    ct = Thesaurus.find_minimum(context_id)
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    params[:tags] = ct.is_owned_by_cdisc? ? ct.tag_labels : []
    children = tc.children_pagination(params)
    children.map{|x| x.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: x[:id], unmanaged_concept: {parent_id: tc.id, context_id: context_id}})})}
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

  def changes_report
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    clis = tc.changes(current_user.max_term_display.to_i)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscChangesReport.new.create(clis, current_user)
        render pdf: "CDISC_CL_#{tc.scoped_identifier}", page_size: current_user.paper_size, orientation: 'Landscape', lowquality: true
      end
    end
  end

  def changes_summary
    authorize Thesaurus, :show?
    @tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    @last = Thesaurus::ManagedConcept.find_with_properties(params[:last_id])
    @version_span = params[:ver_span]
    @tc.synonym_objects
    @tc.preferred_term_objects
    @version_count = 2
    @links = {}
    @close_path = dashboard_index_path
  end

  def changes_summary_data
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    last = Thesaurus::ManagedConcept.find_with_properties(params[:last_id])
    versions = params[:ver_span]
    clis = tc.changes_summary(last, versions)
    clis[:items].each {|k,v| v[:changes_path] = changes_thesauri_unmanaged_concept_path(v[:id])}
    render json: {data: clis}
  end

  def differences
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    render json: {data: tc.differences}
  end

  def differences_summary
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    last = Thesaurus::ManagedConcept.find_with_properties(params[:last_id])
    versions = params[:ver_span]
    render json: {data: tc.differences_summary(last, versions)}
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
    errors = []
    uris = the_params[:extension_ids].map {|x| Uri.new(id: x)}
    if Thesaurus::ManagedConcept.same_type(uris, Thesaurus::UnmanagedConcept.rdf_type)
      tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
      tc.add_extensions(uris)
    else
      errors = ["Not all of the items were code list items."]
    end
    render json: {data: {}, error: errors}
  end

  def destroy_extensions
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    uris = the_params[:extension_ids].map {|x| Uri.new(id: x)}
    tc.delete_extensions(uris)
    render json: {data: {}, error: []}
  end

  #Subsets
  def find_subsets
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    subsets = tc.subsetted_by
    subset_tcs = []
    if !subsets.nil?
      subsets.map{|x| x[:s].to_id}.each{|s|
        mc = Thesaurus::ManagedConcept.find_with_properties(s)
        t = Thesaurus.unique.select{|x| x[:scope_id] == mc.scope.id}
        edit_path = edit_subset_thesauri_managed_concept_path(mc, source_mc: tc.id, context_id: params[:context_id])
        subset_tcs << {:th_label => t[0][:label], :identifier => mc.identifier, :label => mc.label, :edit_path => edit_path}}
    end
    render json: {data: subset_tcs}
  end

  def edit_subset
    authorize Thesaurus, :edit?
    @context_id = params[:context_id]
    @ct = Thesaurus.find_minimum(@context_id)
    @source_mc = Thesaurus::ManagedConcept.find_with_properties(params[:source_mc])
    @subset_mc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    @subset_mc.synonyms_and_preferred_terms
    @subset = Thesaurus::Subset.find(@subset_mc.is_ordered_links)
    @token = get_token(@subset_mc)
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

  def path_for(action, object)
    case action
      when :show
        return thesauri_managed_concept_path({id: object.id, managed_concept: {context_id: object.current_and_latest_parent.last[:uri].to_id}})
      when :search
        return ""
      when :edit
        return edit_thesauri_managed_concept_path({id: object.id, managed_concept: {parent_id: object.current_and_latest_parent.last[:uri].to_id}})
      when :destroy
        return thesauri_managed_concept_path(object)
      else
        return ""
    end
  end

  # Set the history path
  def edit_lock_lost_link(thesaurus)
    return history_thesauri_index_path({thesauri: {identifier: thesaurus.scoped_identifier, scope_id: thesaurus.scope.id}})
  end

  def audit_and_respond(thesaurus, thesaurus_concept, token)
    if thesaurus_concept.errors.empty?
      AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated.") if token.refresh == 1
      results = []
      results << thesaurus_concept.to_json
      render :json => {:data => results}, :status => 200
    else
      render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
    end
  end

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
    #params.require(:managed_concept).permit(:parent_id, :identifier, :context_id, :reference_ct_id, :extension_ids => [])
    params.require(:managed_concept).permit(:parent_id, :identifier, :scope_id, :context_id, :extension_ids => [])
  end

  def edit_params
    params.require(:edit).permit(:notation, :synonym, :definition, :preferred_term, :label, :parent_id)
  end

end
