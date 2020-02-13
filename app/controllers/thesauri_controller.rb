# Thesauri Controller
#
# @author Dave Iberson-Hurst
# @since 0.0.0

require 'controller_helpers.rb'

class ThesauriController < ApplicationController

  include ControllerHelpers

  before_action :authenticate_user!

  # def new
  #   authorize Thesaurus
  #   @thesaurus = Thesaurus.new
  # end

  def index
    authorize Thesaurus
    @thesauri = Thesaurus.unique
    respond_to do |format|
      format.html do
        # @todo This is a bit evil but short term solution. Think of a more elgant fix.
        redirect_to root_path if current_user.is_only_community?
      end
      format.json do
        render json: {data: @thesauri}
      end
    end
  end

  def index_owned
    authorize Thesaurus, :index?
    owner_scoped_id = IsoRegistrationAuthority.repository_scope.id
    render json: {data: Thesaurus.unique.select{|x| x[:scope_id] == owner_scoped_id}}
  end

  def history
    authorize Thesaurus
    respond_to do |format|
      format.html do
        # @todo This is a bit evil but short term solution. Think fo a more elgant fix.
        redirect_to history_cdisc_terms_path if current_user.is_only_community?
        results = Thesaurus.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        if results.empty?
          redirect_to thesauri_index_path
        else
          @thesauri_id = results.first.to_id
          @thesaurus = Thesaurus.find_minimum(@thesauri_id)
          @identifier = the_params[:identifier]
          @scope_id = the_params[:scope_id]
        end
      end
      format.json do
        results = []
        history_results = Thesaurus.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        current = Thesaurus.current(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        results = add_history_paths(Thesaurus, history_results, current)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end

  def show
    authorize Thesaurus
    @ct = Thesaurus.find_minimum(params[:id])
    respond_to do |format|
      format.html do
        @close_path = history_thesauri_index_path({thesauri: {identifier: @ct.scoped_identifier, scope_id: @ct.scope}})
        @edit_tags_path = path_for(:edit_tags, @ct)
      end
      format.json do
        results = []
        tags = @ct.is_owned_by_cdisc? ? @ct.tag_labels : []
        children = @ct.managed_children_pagination({offset: params[:offset], count: params[:count], tags: tags})
        children.each {|c| results << c.reverse_merge!({show_path: thesauri_managed_concept_path({id: c[:id], managed_concept: {context_id: @ct.id}})})}
        render json: {data: results, offset: params[:offset].to_i, count: results.count}, status: 200
      end
    end
  end

  def create
    authorize Thesaurus
    @thesaurus = Thesaurus.create(the_params)
    if @thesaurus.errors.empty?
      AuditTrail.create_item_event(current_user, @thesaurus, @thesaurus.audit_message(:created))
      flash[:success] = 'Terminology was successfully created.'
    else
      flash[:error] = @thesaurus.errors.full_messages.to_sentence
    end
    redirect_to thesauri_index_path
  end

  def clone
    authorize Thesaurus
    ct = Thesaurus.find_minimum(protect_from_bad_id(params))
    th = ct.clone
    th.reset_cloned(the_params)
    if th.errors.empty?
      AuditTrail.create_item_event(current_user, th, th.audit_message(:cloned))
      flash[:success] = 'Terminology was successfully cloned.'
    else
      flash[:error] = th.errors.full_messages.to_sentence
    end
    redirect_to thesauri_index_path
  end

  def edit
    authorize Thesaurus
    @thesaurus = Thesaurus.find_minimum(params[:id])
    @thesaurus = edit_item(@thesaurus)
    if !@thesaurus.nil?
      @close_path = history_thesauri_index_path({thesauri: {identifier: @thesaurus.scoped_identifier, scope_id: @thesaurus.scope}})
      @parent_identifier = ""
    else
      redirect_to request.referrer
    end
  end

  def release_select
    authorize Thesaurus, :edit?
    @thesaurus = Thesaurus.find_minimum(params[:id])
    last_id = Thesaurus.history_uris(identifier: @thesaurus.has_identifier.identifier, scope: @thesaurus.scope).first
    @thesaurus = Thesaurus.find_minimum(last_id)
    @thesaurus = edit_item(@thesaurus)
    if !@thesaurus.nil?
      @close_path = history_thesauri_index_path({thesauri: {identifier: @thesaurus.scoped_identifier, scope_id: @thesaurus.scope}})
      @versions = CdiscTerm.version_dates
      @versions_normalized = normalize_versions(@versions)
      @versions_yr_span = [ @versions[0][:date].split('-')[0], @versions[-1][:date].split('-')[0] ]
      ref_thesaurus = @thesaurus.get_referenced_thesaurus
      @cdisc_date =  ref_thesaurus == nil ? "None" : ref_thesaurus.version_label.split(' ')[0]
      @edit_tags_path = path_for(:edit_tags, @thesaurus)
    else
      redirect_to request.referrer
    end
  end

  def children
    authorize Thesaurus, :edit?
    results = []
    ct = Thesaurus.find_minimum(params[:id])
    children = ct.managed_children_pagination({offset: "0", count: "10000"})
    children.each {|c|
      item = Thesaurus::ManagedConcept.find_minimum(c[:id])
      results << c.reverse_merge!({edit_path: item.subset? ? edit_subset_thesauri_managed_concept_path(item, source_mc: item.subsets_links.to_id, context_id: ct.id) : edit_thesauri_managed_concept_path({id: c[:id], managed_concept: {parent_id: ct.id}}),
      delete_path: thesauri_managed_concept_path({id: c[:id], managed_concept: {parent_id: ct.id}})})
    }
    render :json => { data: results }, :status => 200
  end

  def children_with_indicators
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    children = ct.managed_children_indicators_paginated(the_params)
    render :json => { data: children }, :status => 200
  end

  def add_child
    authorize Thesaurus, :create?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      tc = ct.add_child(the_params)
      if tc.errors.empty?
        AuditTrail.update_item_event(current_user, ct, ct.audit_message(:updated)) if token.refresh == 1
        result = tc.simple_to_h
        result.reverse_merge!({edit_path: edit_thesauri_managed_concept_path({id: tc.id, managed_concept: {parent_id: ct.id}}),
          delete_path: thesauri_managed_concept_path({id: tc.id, managed_concept: {parent_id: ct.id}})})
        render :json => {data: result}, :status => 200
      else
        render :json => {:errors => tc.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => [token_timeout_message]}, :status => 422
    end
  end

  def destroy
    authorize Thesaurus
    thesaurus = Thesaurus.find_minimum(params[:id])
    token = Token.obtain(thesaurus, current_user)
    if !token.nil?
      thesaurus.delete
      AuditTrail.delete_item_event(current_user, thesaurus, thesaurus.audit_message(:deleted))
      token.release
    else
      render :json => {errors: token_destroy_message(thesaurus)}, :status => 422 and return
    end
    render :json => {}, :status => 200
  end

  # Removed.
  # def view
  #   authorize Thesaurus
  #   @thesaurus = Thesaurus.find(params[:id], params[:namespace])
  #   @close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.scope.id)
  # end

  def search
    authorize Thesaurus, :show?
    @thesaurus = Thesaurus.find_minimum(params[:id])
    respond_to do |format|
      format.html
        @close_path = history_thesauri_index_path(thesauri: {identifier: @thesaurus.scoped_identifier, scope_id: @thesaurus.scope.id})
      format.json do
        if Thesaurus.empty_search?(params)
          render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => "0", :data => [] }
        else
          results = @thesaurus.search(params)
          render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => results[:count].to_s, :data => results[:items] }
        end
      end
    end
  end

  # def search_current
  #   authorize Thesaurus, :show?
  #   respond_to do |format|
  #     format.html
  #       @close_path = thesauri_index_path
  #     format.json do
  #       if Thesaurus.empty_search?(params)
  #         render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => "0", :data => [] }
  #       else
  #         results = Thesaurus.search_current(params)
  #         render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => results[:count].to_s, :data => results[:items] }
  #       end
  #     end
  #   end
  # end

  def search_multiple
    authorize Thesaurus, :show?
    filter = the_params[:filter]
    respond_to do |format|
      format.html
        @search_type = filter.nil? ? "Multiple" : filter.capitalize
        @search_filter = filter.nil? ? the_params[:id_set] : filter
        @search_url = search_multiple_thesauri_index_path(thesauri: the_params)
        @close_path = thesauri_index_path
      format.json do
        uris = []
        if filter == "current"
          Thesaurus.current_and_latest_set.each do |key,value|
            value.each do |status|
              uris << status[:current][:uri] if !status[:current].nil?
            end
          end
        elsif filter == "latest"
          Thesaurus.current_and_latest_set.each do |key,value|
            value.each do |status|
              uris << status[:latest][:uri] if !status[:latest].nil?
            end
          end
        else
          uris = the_params[:id_set].map {|x| Uri.new(id: x)}
        end
        if Thesaurus.empty_search?(params)
          render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => "0", :data => [] }
        else
          results = Thesaurus.search_multiple(params, uris)
          render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => results[:count].to_s, :data => results[:items] }
        end
      end
    end
  end

  def changes
    authorize Thesaurus, :show?
    @version_count = current_user.max_term_display.to_i
    @ct = Thesaurus.find_minimum(params[:id])
    link_objects = @ct.forward_backward(1, current_user.max_term_display.to_i)
    @links = {}
    link_objects.each {|k,v| @links[k] = v.nil? ? "" : changes_thesauri_path(v.to_id)}
    @close_path = request.referer #history_thesauri_index_path(thesauri: {identifier: @ct.identifier, scope_id: @ct.owner})
  end

  def changes_data
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    cls = ct.changes(current_user.max_term_display.to_i)
    cls[:items].each do |k,v|
      v[:changes_path] = changes_thesauri_managed_concept_path(v[:id])
    end
    render json: {data: cls}
  end

  def changes_report
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    cls = ct.changes(current_user.max_term_display.to_i)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscChangesReport.new.create(cls, current_user)
        render pdf: "terminology_changes", page_size: current_user.paper_size, orientation: 'Landscape', lowquality: true
      end
    end
  end

  def changes_impact
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    ct_ver = ct.version_label.split(' ')
    ct_new = Thesaurus.find_minimum(the_params[:thesaurus_id])
    ct_new_ver = ct_new.version_label.split(' ')
    sponsor = Thesaurus.find_minimum(the_params[:sponsor_th_id])
    cls = ct.changes_impact_v2(ct_new, sponsor)
    cls.each do |v|
      if v[:cl_new].nil?
        v[:type] = "deleted"
        v[:changes_url] = changes_data_thesauri_managed_concept_path(v[:id])
        v[:differences_url] = differences_thesauri_managed_concept_path(v[:id])
      else
        v[:type] = "updated"
        v[:changes_url] = changes_summary_data_impact_thesauri_managed_concept_path(v[:id], last_id: v[:cl_new], ver_span: [ct_ver[0], ct_new_ver[0]])
        v[:differences_url] = differences_summary_thesauri_managed_concept_path(v[:id], last_id: v[:cl_new], ver_span: [ct_ver[0], ct_new_ver[0]])
      end
      v[:graph_data_url] = impact_thesauri_managed_concept_path(v[:id], the_params[:sponsor_th_id])
    end
    render json: {data: cls}
  end

  def export_csv
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    ct_new = Thesaurus.find_minimum(the_params[:thesaurus_id])
    sponsor = Thesaurus.find_minimum(the_params[:sponsor_th_id])
    send_data Thesaurus.impact_to_csv(ct, ct_new, sponsor), filename: "Impact_report_#{sponsor.scoped_identifier}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

  def submission
    authorize Thesaurus, :show?
    @version_count = current_user.max_term_display.to_i
    @ct = Thesaurus.find_minimum(params[:id])
    link_objects = @ct.forward_backward(1, current_user.max_term_display.to_i)
    @links = {}
    link_objects.each {|k,v| @links[k] = v.nil? ? "" : submission_thesauri_path(v.to_id)}
    @close_path = request.referer
  end

  def submission_data
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    cls = ct.submission(current_user.max_term_display.to_i)
    cls[:items].each do |k,v|
      v[:changes_path] = changes_thesauri_unmanaged_concept_path(v[:id])
    end
    render json: {data: cls}
  end

  def submission_report
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    cls = ct.submission(current_user.max_term_display.to_i)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscSubmissionReport.new.create(cls, current_user)
        @render_args = {pdf: 'cdisc_submission', page_size: current_user.paper_size, orientation: 'Landscape', lowquality: true}
        render @render_args
      end
    end
  end

  def compare
    authorize Thesaurus, :show?
    @close_path = request.referer
    if (params[:id] == the_params[:thesaurus_id])
      flash[:error] = "You cannot compare a Terminology with itself"
      redirect_to @close_path and return
    end
    @th = Thesaurus.find_minimum(params[:id])
    @other_th = Thesaurus.find_minimum(the_params[:thesaurus_id])
    @th, @other_th = @other_th, @th if should_reorder?(@th, @other_th)
  end

  def compare_data
    authorize Thesaurus, :show?
    ct_from = Thesaurus.find_minimum(params[:id])
    ct_to = Thesaurus.find_minimum(the_params[:thesaurus_id])
    results = ct_from.differences(ct_to)
    results.each do |k,v|
      next if k == :versions
      if k == :updated
       v.each {|x| x[:changes_path] = changes_summary_thesauri_managed_concept_path({id: x[:id], last_id: x[:last_id], ver_span: results[:versions]})}
      else
       v.each {|x| x[:changes_path] = changes_thesauri_managed_concept_path(x[:id])}
      end
    end
    render json: {data: results}
  end

  def compare_csv
    authorize Thesaurus, :show?
    ct = Thesaurus.find_minimum(params[:id])
    ct_to = Thesaurus.find_minimum(the_params[:thesaurus_id])
    send_data Thesaurus.compare_to_csv(ct, ct_to), filename: "Compare_#{ct.scoped_identifier}v#{ct.semantic_version}_and_#{ct_to.scoped_identifier}v#{ct_to.semantic_version}.csv", :type => 'text/csv; charset=utf-8; header=present', disposition: "attachment"
  end

  def extension
    authorize Thesaurus, :edit?
    results = Thesaurus.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    th = Thesaurus.find_minimum(results.first)
    th = edit_item(th)
    if !th.nil?
      new_object = th.add_extension(the_params[:concept_id])
      AuditTrail.create_item_event(current_user, th, th.audit_message(:updated))
      AuditTrail.create_item_event(current_user, new_object, new_object.audit_message(:created, "extension"))
      show_path = thesauri_managed_concept_path({id: new_object.id, managed_concept: {context_id: th.id}})
      edit_path = edit_extension_thesauri_managed_concept_path(new_object)
      render json: {show_path: show_path, edit_path: edit_path}, :status => 200
    else
      render json: {errors: [flash[:error]]}, :status => 422
    end
  end

  #  def export_ttl
  #   authorize Thesaurus
  #   item = IsoManaged::find(params[:id], params[:namespace])
  #   send_data to_turtle(item.triples), filename: "#{item.owner_short_name}_#{item.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  # end

  # def impact
  # 	authorize Thesaurus
  # 	@thesaurus = Thesaurus.find(params[:id], params[:namespace])
  # 	@start_path = impact_start_thesauri_index_path
  # end

  # def impact_start
  # 	authorize Thesaurus, :impact?
  # 	@thesaurus = Thesaurus.find(params[:id], params[:namespace])
  # 	render json: @thesaurus.impact
  # end

  # def impact_report
  # 	authorize Thesaurus, :impact?
  # 	results = []
  # 	thesaurus = Thesaurus.find(params[:id], params[:namespace])
  # 	results = impact_report_start(thesaurus)
  # 	respond_to do |format|
  #     format.pdf do
  #       @html =Reports::ThesaurusImpactReport.new.create(thesaurus, results, current_user)
  #       @render_args = {pdf: 'impact_analysis', page_size: current_user.paper_size, lowquality: true}
  #       render @render_args
  #     end
  #   end
  # end

  def add_subset
    authorize Thesaurus, :edit?
    results = Thesaurus.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    thesaurus = Thesaurus.find_minimum(results.first)
    thesaurus = edit_item(thesaurus)
    new_mc = thesaurus.add_subset(the_params[:concept_id])
    AuditTrail.create_item_event(current_user, new_mc, new_mc.audit_message(:updated, "subset"))
    path = edit_subset_thesauri_managed_concept_path(new_mc, source_mc: the_params[:concept_id], context_id: thesaurus.id)
    render json: { edit_path: path, }, :status => 200
  end

  def set_reference
    authorize Thesaurus, :edit?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      ref_ct = Thesaurus.find_minimum(the_params[:thesaurus_id])
      ct.set_referenced_thesaurus(ref_ct)
      render :json => {}, :status => 200
    else
      render :json => {:errors => [token_timeout_message]}, :status => 422
    end
  end

  # These should be in private!!!!!
  #
	# def path_for(action, object)
  #   case action
  #     when :show
  #       return thesauri_path(object)
  #     when :search
  #       return search_thesauri_path(object)
  #     when :edit
  #       #return edit_thesauri_path(object)          # Edit view
  #       return release_select_thesauri_path(object) # Select view
  #     when :destroy
  #       return thesauri_path(object)
  #     when :edit_tags
  #       return object.supporting_edit? ? edit_tags_iso_concept_path(object) : ""
  #     when :impact
  #       return object.get_referenced_thesaurus.nil? ? "" : impact_iso_managed_v2_path(object, iso_managed: {new_th_id: "thId"})
  #     else
  #       return ""
  #   end
  # end

  # def impact_report_start(thesaurus)
		# initial_results = []
		# results = {}
		# thesaurus.impact.each do |x|
  # 		uri = UriV2.new({uri: x})
	 #  	initial_results += impact_report_node(uri.id, uri.namespace) { |a,b|
  # 			item = ThesaurusConcept.find(a, b)
  # 			item.set_parent
  # 			item
  # 		}
  # 	end
  # 	initial_results.each do |result|
  # 		if results.has_key?(result[:root].uri)
  # 			results[result[:root].uri.to_s][:children] += result[:children]
  # 		else
  # 			results[result[:root].uri.to_s] = { root: result[:root].to_json, children: result[:children] }
  # 		end
  # 	end
  # 	results.each do |k,v|
  # 		v[:children] = v[:children].inject([]) do |new_children, item|
  # 			new_children << { uri: item[:uri].to_s }
  # 		end
  # 	end
  # 	return results
  # end

  def get_reference
    authorize Thesaurus, :edit?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      ref_ct = ct.get_referenced_thesaurus
      render json: { data: ref_ct.nil? ? {} : ref_ct.to_h }, :status => 200
    else
      render :json => {:errors => [token_timeout_message]}, :status => 422
    end
  end

  def change_child_version
    authorize Thesaurus, :edit?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      ids = the_params[:id_set]
      ct.deselect_children({id_set: [ids[0]]})
      ct.select_children({id_set: [ids[1]]})
      render :json => {}, :status => 200
    else
      render :json => {:errors => [token_timeout_message]}, :status => 422
    end
  end

  def select_children
    authorize Thesaurus, :edit?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      ct.select_children(the_params)
      render :json => {}, :status => 200
    else
      render :json => {:errors => [token_timeout_message]}, :status => 422
    end
  end

  def deselect_children
    authorize Thesaurus, :edit?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      ct.deselect_children(the_params)
      render :json => {}, :status => 200
    else
      render :json => {:errors => [token_timeout_message]}, :status => 422
    end
  end

  def deselect_all_children
    authorize Thesaurus, :edit?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      ct.deselect_all_children
      render :json => {}, :status => 200
    else
      render :json => {:errors => [token_timeout_message]}, :status => 422
    end
  end

private

  def should_reorder? (first, second)
    return (first.same_item?(second) && second.earlier_version?(first))
  end

  # Path for given action
  def path_for(action, object)
    case action
      when :show
        return thesauri_path(object)
      when :search
        return search_thesauri_path(object)
      when :edit
        #return edit_thesauri_path(object)          # Edit view
        return release_select_thesauri_path(object) # Select view
      when :destroy
        return thesauri_path(object)
      when :edit_tags
        return object.supporting_edit? ? edit_tags_iso_concept_path(object) : ""
      when :impact
        return object.get_referenced_thesaurus.nil? ? "" : impact_iso_managed_v2_path(object, iso_managed: {new_th_id: "thId"})
      when :clone
        return clone_thesauri_path(object)
      when :compare
        return compare_thesauri_path(object)
      else
        return ""
    end
  end

  # Strong params
  def the_params
    #params.require(:thesauri).permit(:identifier, :scope_id, :offset, :count, :label, :concept_id, :reference_ct_id)
    params.require(:thesauri).permit(:identifier, :scope_id, :offset, :count, :label, :concept_id, :thesaurus_id, :sponsor_th_id, :filter, :id_set => [])
  end

end
