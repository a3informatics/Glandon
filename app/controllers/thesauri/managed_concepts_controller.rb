# Thesauri Manged Concepts Controller
#
# @author Dave Iberson-Hurst
# @since 0.0.0

require 'controller_helpers.rb'

class Thesauri::ManagedConceptsController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  C_CLASS_NAME = "ThesaurusConceptsController"

  def index
    authorize Thesaurus
    # @tcs = Thesaurus::ManagedConcept.unique
  end

  def history
    authorize Thesaurus
    respond_to do |format|
      format.html do
        # @todo This is a bit evil but short term solution. Think fo a more elgant fix.
        results = Thesaurus::ManagedConcept.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        if results.empty?
          redirect_to thesauri_managed_concepts_path
        else
          @thesauri_id = results.first.to_id
          @thesaurus = Thesaurus.find_minimum(@thesauri_id)
          @identifier = the_params[:identifier]
          @scope_id = the_params[:scope_id]
        end
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

  def create
    authorize Thesaurus
    object = Thesaurus::ManagedConcept.create
    if object.errors.empty?
      result = object.to_h
      result[:history_path] = history_thesauri_managed_concepts_path({managed_concept: {identifier: object.scoped_identifier, scope_id: object.scope}})
      render :json => { data: result}, :status => 200
    else
      render :json => {:errors => tc.errors.full_messages}, :status => 422
    end
  rescue => e
      render :json => {:errors => [e.message]}, :status => 422
  end

  def set_with_indicators
    authorize Thesaurus, :show?
    results = Thesaurus::ManagedConcept.set_with_indicators_paginated(set_params)
    results.each do |x|
      x.reverse_merge!({history_path: history_thesauri_managed_concepts_path({id: x[:id],
        managed_concept: {identifier: x[:scoped_identifier], scope_id: x[:scope_id]}})})
    end
    render :json => { data: results, offset: set_params[:offset].to_i, count: results.count }, :status => 200
  end

  def edit
    authorize Thesaurus
    @thesaurus_concept = read_concept(protect_from_bad_id(params))
    if !@thesaurus_concept.nil?
      @close_path = history_thesauri_managed_concepts_path({managed_concept: {identifier: @thesaurus_concept.scoped_identifier, scope_id: @thesaurus_concept.scope}})
      @tc_identifier_prefix = "#{@thesaurus_concept.identifier}."
    else
      redirect_to request.referrer
    end
  end

  def edit_extension
    authorize Thesaurus, :edit?
    @tc = read_concept(protect_from_bad_id(params))
    if !@tc.nil?
      extension_of_uri = @tc.extension_of
      @is_extending = !extension_of_uri.nil?
      @is_extending_path = extension_of_uri.nil? ? "" : thesauri_managed_concept_path({id: extension_of_uri.to_id, managed_concept: {context_id: @context_id}})
      @close_path = history_thesauri_managed_concepts_path({managed_concept: {identifier: @tc.scoped_identifier, scope_id: @tc.scope}})
    else
      redirect_to request.referrer
    end
  end

  def edit_subset
    authorize Thesaurus, :edit?
    @subset_mc = read_concept(protect_from_bad_id(params))
    if !@subset_mc.nil?
      @subset_mc.subsets_links
      @source_mc = Thesaurus::ManagedConcept.find_with_properties(@subset_mc.subsets)
      @subset_mc.synonyms_and_preferred_terms
      @subset = Thesaurus::Subset.find(@subset_mc.is_ordered_links)
      @close_path = history_thesauri_managed_concepts_path({managed_concept: {identifier: @subset_mc.scoped_identifier, scope_id: @subset_mc.scope}})
    else
      redirect_to request.referrer
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
        result = tc.simple_to_h
        render :json => {:data => [result]}, :status => 200
      else
        render :json => {:errors => tc.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The edit lock has timed out."]}, :status => 422
    end
  end

  def children
    authorize Thesaurus, :edit?
    results = []
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    children = tc.children_pagination({offset: "0", count: "10000"})
    children.each do |c|
      edit_path = Thesaurus::ManagedConcept.identifier_scheme_flat? ? "" : edit_thesauri_unmanaged_concept_path({id: c[:id], unmanaged_concept: {parent_id: tc.id}})
      delete_path = thesauri_unmanaged_concept_path({id: c[:id], unmanaged_concept: {parent_id: tc.id}})
      results << c.reverse_merge!({edit_path: edit_path, delete_path: delete_path})
    end
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
        edit_path = Thesaurus::ManagedConcept.identifier_scheme_flat? ? "" : edit_thesauri_unmanaged_concept_path({id: result[:id], unmanaged_concept: {parent_id: tc.id}})
        delete_path = thesauri_unmanaged_concept_path({id: result[:id], unmanaged_concept: {parent_id: tc.id}})
        result.reverse_merge!({edit_path: edit_path, delete_path: delete_path})
        render :json => {data: result}, :status => 200
      else
        render :json => {:errors => new_tc.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The changes were not saved as the edit lock has timed out."]}, :status => 422
    end
  end

  def add_children_synonyms
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    uc = Thesaurus::UnmanagedConcept.find(the_params[:reference_id])
    children = tc.add_children_based_on(uc)
    render :json => {data: "" }, :status => 200
  end

  def destroy
    authorize Thesaurus
    tc = Thesaurus::ManagedConcept.find_minimum(protect_from_bad_id(params))
    token = get_token(tc)
    if !token.nil?
      if tc.delete_or_unlink == 1
        AuditTrail.update_item_event(current_user, tc, "Code list sucessfully deleted.")
        render :json => {}, :status => 200
      else
        render :json => {:errors => tc.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The code list cannot be deleted as it is being edited by another user."]}, :status => 422
    end
  end

  def export_csv
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_full(params[:id])
    send_data tc.to_csv, filename: "CDISC_CL_#{tc.scoped_identifier}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

  def show
    authorize Thesaurus
    @tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
    @tc.synonym_objects
    @tc.preferred_term_objects
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
    tc = Thesaurus::ManagedConcept.find_with_properties(params[:id])
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

  def create_extension
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    new_object = tc.create_extension
    show_path = thesauri_managed_concept_path({id: new_object.id, managed_concept: {context_id: tc.id}})
    edit_path = edit_extension_thesauri_managed_concept_path(new_object)
    render json: {show_path: show_path, edit_path: edit_path}, :status => 200
  end

  def add_extensions
    authorize Thesaurus, :edit?
    errors = []
    uris = the_params[:extension_ids].map {|x| Uri.new(id: x)}
    if Thesaurus::ManagedConcept.same_type(uris, Thesaurus::UnmanagedConcept.rdf_type)
      tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
      token = Token.find_token(tc, current_user)
      if !token.nil?
        tc.add_extensions(uris)
        render json: {data: {}, error: errors}
      else
        render :json => {:errors => ["The edit lock has timed out."]}, :status => 422
      end
    else
      render :json => {:errors => ["Not all of the items were code list items."]}, :status => 422
    end
  end

  def destroy_extensions
    authorize Thesaurus, :edit?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    token = Token.find_token(tc, current_user)
    if !token.nil?
      uris = the_params[:extension_ids].map {|x| Uri.new(id: x)}
      tc.delete_extensions(uris)
      render json: {data: {}, error: []}, :status => 200
    else
      render :json => {:errors => ["The edit lock has timed out."]}, :status => 422
    end
  end

  #Subsets

  def create_subset
    authorize Thesaurus, :create?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    new_mc = tc.create_subset
    path = edit_subset_thesauri_managed_concept_path(new_mc, source_mc: new_mc.subsets_links.to_id, context_id: params[:ctxt_id])
    render json: { redirect_path: path, }, :status => 200
  end

  def find_subsets
    authorize Thesaurus, :show?
    tc = Thesaurus::ManagedConcept.find_minimum(params[:id])
    subsets = tc.subsetted_by
    subset_tcs = []
    if !subsets.nil?
      subsets.map{|x| x[:s].to_id}.each{|s|
        mc = Thesaurus::ManagedConcept.find_with_properties(s)
        subset_item = mc.simple_to_h
        subset_item[:edit_path] = edit_subset_thesauri_managed_concept_path(mc, source_mc: tc.id, context_id: params[:context_id])
        subset_tcs << subset_item
      }
    end
    render json: {data: subset_tcs}
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

  # Read a Thesaurus Concept
  def read_concept(id)
    tc = Thesaurus::ManagedConcept.find_with_properties(id)
    tc = edit_item(tc)
    return nil if tc.nil?
    tc.synonyms_and_preferred_terms
    tc
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
        return object.supporting_edit? ? edit_tags_iso_concept_path(object) : ""
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

  # Audit and respond
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

  def the_params
    params.require(:managed_concept).permit(:parent_id, :identifier, :scope_id, :context_id, :offset, :count, :reference_id, :extension_ids => [])
  end

  def set_params
    params.require(:managed_concept).permit(:type, :offset, :count)
  end

  def edit_params
    params.require(:edit).permit(:notation, :synonym, :definition, :preferred_term, :label, :parent_id)
  end

  # Not required currently, will be for user-defined identifiers
  def create_params
    params.require(:edit).permit(:identifier)
  end

end
