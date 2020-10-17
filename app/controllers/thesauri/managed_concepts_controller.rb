# Thesauri Manged Concepts Controller
#
# @author Dave Iberson-Hurst
# @since 0.0.0

require 'controller_helpers'

class Thesauri::ManagedConceptsController < ManagedItemsController

  include ControllerHelpers
  include DatatablesHelpers

  before_action :authenticate_user!

  def index
    authorize Thesaurus
  end

  def history
    authorize Thesaurus
    respond_to do |format|
      format.html do
        results = Thesaurus::ManagedConcept.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        if results.empty?
          redirect_to thesauri_managed_concepts_path
        else
          @tc = Thesaurus::ManagedConcept.find_minimum(results.first.to_id)
          @identifier = the_params[:identifier]
          @scope_id = the_params[:scope_id]
          @close_path = thesauri_managed_concepts_path
        end
      end
      format.json do
        results = []
        history_results = Thesaurus::ManagedConcept.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = Thesaurus::ManagedConcept.current_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        latest = Thesaurus::ManagedConcept.latest_uri(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Thesaurus::ManagedConcept, history_results, current, latest)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

  def create
    authorize Thesaurus
    object = Thesaurus::ManagedConcept.create
    return true if item_errors(object)
    AuditTrail.create_item_event(current_user, object, object.audit_message(:created))
    result = object.to_h
    result[:history_path] = history_thesauri_managed_concepts_path({managed_concept: {identifier: object.scoped_identifier, scope_id: object.scope}})
    render :json => { data: result}, :status => 200
  rescue => e
      render :json => {errors: [e.message]}, :status => 422
  end

  def set_with_indicators
    authorize Thesaurus, :show?
    results = Thesaurus::ManagedConcept.set_with_indicators_paginated(set_params)
    results.each do |x|
      x.reverse_merge!({history_path: history_thesauri_managed_concepts_path({id: x[:id],
        managed_concept: {identifier: x[:scoped_identifier], scope_id: x[:scope_id]}})})
    end
    render :json => {data: results, offset: set_params[:offset].to_i, count: results.count}, :status => 200
  end

  def edit
    authorize Thesaurus
    return true unless read_concept(protect_from_bad_id(params))
    @thesaurus_concept = @edit.item
    @thesaurus_concept.synonyms_and_preferred_terms
    @close_path = history_thesauri_managed_concepts_path({managed_concept: {identifier: @thesaurus_concept.scoped_identifier, scope_id: @thesaurus_concept.scope}})
    @tc_identifier_prefix = "#{@thesaurus_concept.identifier}."
    @edit_tags_path = path_for(:edit_tags, @thesaurus_concept)
  end

  def edit_extension
    authorize Thesaurus, :edit?
    return true unless read_concept(protect_from_bad_id(params))
    @tc = @edit.item
    @tc.synonyms_and_preferred_terms
    extension_of_uri = @tc.extension_of
    @is_extending = !extension_of_uri.nil?
    @is_extending_path = extension_of_uri.nil? ? "" : thesauri_managed_concept_path({id: extension_of_uri.to_id, managed_concept: {context_id: @context_id}})
    @close_path = history_thesauri_managed_concepts_path({managed_concept: {identifier: @tc.scoped_identifier, scope_id: @tc.scope}})
    @edit_tags_path = path_for(:edit_tags, @tc)
  end

  def edit_subset
    authorize Thesaurus, :edit?
    return true unless read_concept(protect_from_bad_id(params))
    @subset_mc = @edit.item
    @subset_mc.subsets_links
    @source_mc = Thesaurus::ManagedConcept.find_with_properties(@subset_mc.subsets)
    @subset_mc.synonyms_and_preferred_terms
    @subset = Thesaurus::Subset.find(@subset_mc.is_ordered_links)
    @close_path = history_thesauri_managed_concepts_path({managed_concept: {identifier: @subset_mc.scoped_identifier, scope_id: @subset_mc.scope}})
    @edit_tags_path = path_for(:edit_tags, @subset_mc)
  end

  def update
    authorize Thesaurus
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    tc.synonyms_and_preferred_terms
    ct = Thesaurus.find_minimum(edit_params[:parent_id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      tc = tc.update(edit_params)
      if tc.errors.empty?
        AuditTrail.update_item_event(current_user, tc, tc.audit_message(:updated)) if token.refresh == 1
        result = tc.simple_to_h
        result.reverse_merge!({edit_path: edit_thesauri_managed_concept_path({id: tc.id, managed_concept: {parent_id: ct.id}}), delete_path: thesauri_managed_concept_path(tc)})
        render :json => {data: [result]}, :status => 200
      else
        render :json => {fieldErrors: format_editor_errors(tc.errors)}, :status => 200
      end
    else
      flash[:error] = token_timeout_message
      render :json => {data: {}, link: edit_lock_lost_link(th)}, :status => 422
    end
  end

  def update_properties
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    return true unless check_lock_for_item(tc)
    tc.synonyms_and_preferred_terms
    tc = tc.update(edit_params)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, tc, tc.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: [tc.simple_to_h]}, :status => 200
  end

  def children
    authorize Thesaurus, :edit?
    results = []
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    children = tc.children_pagination({offset: "0", count: "10000"})
    children.each do |c|
      show_path = thesauri_unmanaged_concept_path({id: c[:id], unmanaged_concept: {parent_id: tc.id}})
      edit_path = Thesaurus::ManagedConcept.identifier_scheme_flat? ? "" : edit_thesauri_unmanaged_concept_path({id: c[:id], unmanaged_concept: {parent_id: tc.id}})
      delete_path = thesauri_unmanaged_concept_path({id: c[:id], unmanaged_concept: {parent_id: tc.id}})
      edit_tags_path = c[:referenced] ? "" : edit_tags_iso_concept_path(id: c[:id], iso_concept: {parent_id: tc.id})
      results << c.reverse_merge!({show_path: show_path, edit_path: edit_path, delete_path: delete_path, edit_tags_path: edit_tags_path})
    end
    render :json => {data: results}, :status => 200
  end

  def add_child
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    return true unless check_lock_for_item(tc)
    new_tc = tc.add_child(the_params)
    return true if item_errors(new_tc)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, tc, tc.audit_message(:updated)) if @lock.token.refresh == 1
    result = new_tc.simple_to_h
    edit_path = Thesaurus::ManagedConcept.identifier_scheme_flat? ? "" : edit_thesauri_unmanaged_concept_path({id: result[:id], unmanaged_concept: {parent_id: tc.id}})
    delete_path = thesauri_unmanaged_concept_path({id: result[:id], unmanaged_concept: {parent_id: tc.id}})
    result.reverse_merge!({edit_path: edit_path, delete_path: delete_path })
    render :json => {data: result}, :status => 200
  end

  def add_children
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    return true unless check_lock_for_item(tc)
    tc.add_referenced_children(children_params[:set_ids])
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, tc, tc.audit_message(:updated)) if @lock.token.refresh == 1
    render :json => {data: "" }, :status => 200
  end

  def add_children_synonyms
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    return true unless check_lock_for_item(tc)
    uc = Thesaurus::UnmanagedConcept.find(the_params[:reference_id])
    children = tc.add_children_based_on(uc)
    return true if item_errors(children.first)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, tc, tc.audit_message(:updated))
    render :json => {data: "" }, :status => 200
  end

  def destroy
    authorize Thesaurus
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    token = get_token(tc)
    if !token.nil?
      if tc.delete_or_unlink == 1
        AuditTrail.delete_item_event(current_user, tc, tc.audit_message(:deleted))
        render :json => {}, :status => 200
      else
        render :json => {errors: tc.errors.full_messages}, :status => 422
      end
    else
      render :json => {errors: [token_destroy_message(tc)]}, :status => 422
    end
  end

  def export_csv
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_full(protect_from_bad_id(params))
    send_data tc.to_csv, filename: "CDISC_CL_#{tc.scoped_identifier}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

  def show
    authorize Thesaurus
    @tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    @tc.synonym_objects
    @tc.preferred_term_objects
    @can_extend_unextensible = Thesaurus::ManagedConcept.can_extend_unextensible?
    @can_be_extended = @tc.extensible && !@tc.extended?
    extended_by_uri = @tc.extended_by
    @is_extended = !extended_by_uri.nil?
    extension_of_uri = @tc.extension_of
    @is_extending = !extension_of_uri.nil?
    @context_id = the_params[:context_id]
    if @context_id.blank?
      @close_path = history_thesauri_managed_concepts_path({managed_concept: {identifier: @tc.scoped_identifier, scope_id: @tc.scope}})
    else
      @ct = Thesaurus.find_minimum(@context_id)
      @close_path = thesauri_path(@ct)
    end
    @is_extending_path = extension_of_uri.nil? ? "" : thesauri_managed_concept_path({id: extension_of_uri.to_id, managed_concept: {context_id: @context_id}})
    @is_extended_path = extended_by_uri.nil? ? "" : thesauri_managed_concept_path({id: extended_by_uri.to_id, managed_concept: {context_id: @context_id}})
    @edit_tags_path = path_for(:edit_tags, @tc)
  end

  def show_data
    authorize Thesaurus, :show?
    context_id = the_params[:context_id]
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    if !context_id.blank?
      ct = Thesaurus.find_minimum(context_id)
      params[:tags] = ct.is_owned_by_cdisc? ? ct.tag_labels : []
    else
      params[:tags] = []
    end
    children = tc.children_pagination(params)
    children.map{|x| x.reverse_merge!({show_path: thesauri_unmanaged_concept_path({id: x[:id], unmanaged_concept: {parent_id: tc.id, context_id: context_id}})})}
    results = children.map{|x| x.reverse_merge!({delete_path: x[:delete] ? thesauri_unmanaged_concept_path({id: x[:id], unmanaged_concept: {parent_id: tc.id}}) : "" })}
    results = children.map{|x| x.reverse_merge!({single_parent: x[:single_parent]})}
    render json: {data: results, offset: params[:offset].to_i, count: results.count}, status: 200
  end

  def changes
    authorize Thesaurus, :show?
    @tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
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
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    clis = tc.changes(current_user.max_term_display.to_i)
    clis[:items].each {|k,v| v[:changes_path] = changes_thesauri_unmanaged_concept_path(v[:id])}
    render json: {data: clis}
  end

  def changes_report
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
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
    @tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
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
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    last = Thesaurus::ManagedConcept.find_with_properties(params[:last_id])
    versions = params[:ver_span]
    clis = tc.changes_summary(last, versions)
    clis[:items].each {|k,v| v[:changes_path] = changes_thesauri_unmanaged_concept_path(v[:id])}
    render json: {data: clis}
  end

  def changes_summary_data_impact
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    last = Thesaurus::ManagedConcept.find_with_properties(params[:last_id])
    versions = params[:ver_span]
    clis = tc.changes_summary_impact(last, versions)
    clis[:items].each {|k,v| v[:changes_path] = changes_thesauri_unmanaged_concept_path(v[:id])}
    render json: {data: clis}
  end

  def impact
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    ct = Thesaurus.find_minimum(impact_params[:sponsor_th_id])
    render json: {data: tc.impact(ct)}
  end

  def upgrade
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    return true unless get_lock_for_item(tc)
    tc.synonyms_and_preferred_terms
    ct = Thesaurus.find_minimum(upgrade_params[:sponsor_th_id])
    item = tc.upgrade(ct)
    @lock.release
    return true if lock_item_errors
    render json: {data: {}}
  end

  def upgrade_data
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    ct = Thesaurus.find_minimum(impact_params[:sponsor_th_id])
    results = tc.upgrade_impact(ct)
    results.each do |x|
      tc = Thesaurus::ManagedConcept.find_minimum(x[:id])
      x[:upgraded] = tc.respond_to?(:upgraded?) ? tc.upgraded?(ct) : true
    end
    render json: {data: results}
  end

  def differences
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    render json: {data: tc.differences}
  end

  def differences_summary
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    last = Thesaurus::ManagedConcept.find_with_properties(params[:last_id])
    versions = params[:ver_span]
    render json: {data: tc.differences_summary(last, versions)}
  end

  def is_extended
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    render json: {data: tc.extended?}
  end

  def is_extension
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    render json: {data: tc.extension?}
  end

  def create_extension
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    new_object = tc.create_extension
    return true if item_errors(new_object)
    AuditTrail.create_item_event(current_user, new_object, new_object.audit_message(:created, "extension"))
    show_path = thesauri_managed_concept_path({id: new_object.id, managed_concept: {context_id: ""}})
    edit_path = edit_extension_thesauri_managed_concept_path(new_object)
    render json: {show_path: show_path, edit_path: edit_path}, status: 200
  end

  def add_extensions
    authorize Thesaurus, :edit?
    if Thesaurus::ManagedConcept.same_type(the_params[:extension_ids], Thesaurus::UnmanagedConcept.rdf_type)
      tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
      return true unless check_lock_for_item(tc)
      tc.add_referenced_children(the_params[:extension_ids])
      return true if lock_item_errors
      AuditTrail.create_item_event(current_user, tc, tc.audit_message(:updated))
      render json: {data: {}, errors: []}
    else
      render :json => {errors: ["Not all of the items were code list items."]}, :status => 422
    end
  end

  def create_subset
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    new_mc = tc.create_subset
    return true if item_errors(new_mc)
    AuditTrail.create_item_event(current_user, new_mc, new_mc.audit_message(:created, "subset"))
    path = edit_subset_thesauri_managed_concept_path(new_mc, source_mc: new_mc.subsets_links.to_id, context_id: "" )
    render json: {edit_path: path}, status: 200
  end

  def find_subsets
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    subsets = tc.subsetted_by
    subset_tcs = []
    if !subsets.nil?
      subsets.map{|x| x[:s].to_id}.each{|s|
        mc = Thesaurus::ManagedConcept.find_with_properties(s)
        next if !mc.latest?
        subset_item = mc.simple_to_h
        subset_item[:edit_path] = edit_subset_thesauri_managed_concept_path(mc, source_mc: tc.id, context_id: params[:context_id])
        subset_item[:show_path] = thesauri_managed_concept_path(mc, managed_concept: {context_id: ""})
        subset_tcs << subset_item
      }
    end
    render json: {data: subset_tcs}
  end

  def add_rank
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    rank = tc.add_rank
    actual_rank = Thesaurus::Rank.find(rank.uri)
    if actual_rank.errors.empty?
      render json: { }, :status => 200
    else
      render :json => {:errors => ["Something went wrong while enabling Rank"]}, :status => 422
    end
  end

  def update_rank
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    rank = Thesaurus::Rank.find(tc.is_ranked_links)
    rank.update(rank_params[:children_ranks])
    render json: { }, status: 200
  end

  def children_ranked
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    results = tc.children_pagination({offset: "0", count: "10000"})
    render json: {data: results, offset: params[:offset], count: results.count}, status: 200
  end

  def remove_rank
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    rank = Thesaurus::Rank.find(tc.is_ranked_links)
    rank.remove_all
    render json: { }, status: 200
  end

  def pair
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_with_properties(protect_from_bad_id(params))
    return true unless check_lock_for_item(tc)
    tc.validate_and_pair(pairs_params[:reference_id])
    return true if item_errors(tc)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, tc, tc.audit_message(:paired))
    render :json => {data: {}, errors: []}, :status => 200
  end

  def unpair
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    return true unless check_lock_for_item(tc)
    tc.validate_and_unpair
    return true if item_errors(tc)
    return true if lock_item_errors
    AuditTrail.update_item_event(current_user, tc, tc.audit_message(:unpaired))
    render :json => {data: {}, errors: []}, :status => 200
  end

private

  # Read a Thesaurus Concept
  def read_concept(id)
    tc = Thesaurus::ManagedConcept.find_with_properties(id)
    latest_uri = Thesaurus::ManagedConcept.latest_uri(identifier: tc.has_identifier.identifier, scope: tc.scope)
    tc = Thesaurus::ManagedConcept.find_with_properties(latest_uri)
    return false unless edit_lock(tc)
    @token = @edit.token # such that view can have access
    tc.synonyms_and_preferred_terms
    tc
    true
  end

  def path_for(action, object)
    case action
      when :show
        return thesauri_managed_concept_path({id: object.id, managed_concept: {context_id: latest_parent(object)}})
      when :search
        return ""
      when :edit
        if object.extension?
          return edit_extension_thesauri_managed_concept_path({id: object.id, managed_concept: {parent_id: latest_parent(object)}})
        elsif object.subset?
          return edit_subset_thesauri_managed_concept_path({id: object.id, managed_concept: {parent_id: latest_parent(object)}})
        else
          return edit_thesauri_managed_concept_path({id: object.id, managed_concept: {parent_id: latest_parent(object)}})
        end
      when :destroy
        return thesauri_managed_concept_path(object)
      when :edit_tags
        return object.supporting_edit? ? edit_tags_iso_concept_path(id: object.id) : ""
      when :list_change_notes
        return object.supporting_edit? ? list_change_notes_iso_managed_v2_path(:id => object.id) : ""
      else
        return ""
    end
  end

  def latest_parent(object)
    object.current_and_latest_parent.last[:uri].to_id
  rescue => e
    return ""
  end

  # Set the history path
  def edit_lock_lost_link(object)
    return history_thesauri_managed_concepts_path({managed_concept: {identifier: object.scoped_identifier, scope_id: object.scope.id}})
  end

  def the_params
    params.require(:managed_concept).permit(:parent_id, :identifier, :scope_id, :context_id, :offset, :count, :reference_id, :extension_ids => [])
  end

  def children_params
    params.require(:managed_concept).permit(:set_ids => [])
  end

  def pairs_params
    params.require(:managed_concept).permit(:reference_id)
  end

  def rank_params
     params.require(:managed_concept).permit(:children_ranks => [:cli_id, :rank])
  end

  def set_params
    params.require(:managed_concept).permit(:type, :offset, :count)
  end

  def edit_params
    params.require(:edit).permit(:notation, :synonym, :definition, :preferred_term, :label, :parent_id).to_h
  end

  def impact_params
    params.require(:impact).permit(:sponsor_th_id)
  end

  def upgrade_params
    params.require(:upgrade).permit(:sponsor_th_id)
  end

  # Not required currently, will be for user-defined identifiers
  def create_params
    params.require(:edit).permit(:identifier)
  end

end
