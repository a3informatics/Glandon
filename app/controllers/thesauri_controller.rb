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
        results = add_history_paths(Thesaurus, :thesauri, history_results, current)
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
      AuditTrail.create_item_event(current_user, @thesaurus, "Terminology created.")
      flash[:success] = 'Terminology was successfully created.'
    else
      flash[:error] = @thesaurus.errors.full_messages.to_sentence
    end
    redirect_to thesauri_index_path
  end

  def edit
    authorize Thesaurus
    @thesaurus = Thesaurus.find_minimum(params[:id])
    @thesaurus = edit_item(@thesaurus)
    @close_path = history_thesauri_index_path({thesauri: {identifier: @thesaurus.scoped_identifier, scope_id: @thesaurus.scope}})
    @parent_identifier = ""
  end

  def release_select
    authorize Thesaurus, :edit?
    @thesaurus = Thesaurus.find_minimum(params[:id])
    @close_path = history_thesauri_index_path({thesauri: {identifier: @thesaurus.scoped_identifier, scope_id: @thesaurus.scope}})
    @versions = CdiscTerm.version_dates
    @versions_normalized = normalize_versions(@versions)
    @versions_yr_span = [ @versions[0][:date].split('-')[0], @versions[-1][:date].split('-')[0] ]
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

  def add_child
    authorize Thesaurus, :create?
    ct = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(ct, current_user)
    if !token.nil?
      tc = ct.add_child(the_params)
      if tc.errors.empty?
        AuditTrail.update_item_event(current_user, ct, "Terminology updated.") if token.refresh == 1
        result = tc.simple_to_h
        result.reverse_merge!({edit_path: edit_thesauri_managed_concept_path({id: tc.id, managed_concept: {parent_id: ct.id}}), delete_path: thesauri_managed_concept_path(tc)})
        render :json => {data: result}, :status => 200
      else
        render :json => {:errors => tc.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The changes were not saved as the edit lock has timed out."]}, :status => 422
    end
  end

  def destroy
    authorize Thesaurus
    thesaurus = Thesaurus.find_minimum(params[:id])
    token = Token.obtain(thesaurus, current_user)
    if !token.nil?
      thesaurus.delete
      AuditTrail.delete_item_event(current_user, thesaurus, "Terminology deleted.")
      token.release
    else
      flash[:error] = "The item is locked for editing by another user."
    end
    redirect_to request.referer
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

  def search_current
    authorize Thesaurus, :show?
    respond_to do |format|
      format.html
        @close_path = thesauri_index_path
      format.json do
        if Thesaurus.empty_search?(params)
          render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => "0", :data => [] }
        else
          results = Thesaurus.search_current(params)
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

  def extension
    authorize Thesaurus, :edit?
    results = Thesaurus.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    thesaurus = Thesaurus.find_minimum(results.first)
    thesaurus = edit_item(thesaurus)
    new_object = thesaurus.add_extension(the_params[:concept_id])
    #render json: {show_path: thesauri_managed_concept_path({id: new_object.id, managed_concept: {context_id: thesaurus.id, reference_ct_id: the_params[:reference_ct_id]}})}, :status => 200
    render json: {show_path: thesauri_managed_concept_path({id: new_object.id, managed_concept: {context_id: thesaurus.id}})}, :status => 200
  end

   def export_ttl
    authorize Thesaurus
    item = IsoManaged::find(params[:id], params[:namespace])
    send_data to_turtle(item.triples), filename: "#{item.owner_short_name}_#{item.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end

  def impact
  	authorize Thesaurus
  	@thesaurus = Thesaurus.find(params[:id], params[:namespace])
  	@start_path = impact_start_thesauri_index_path
  end

  def impact_start
  	authorize Thesaurus, :impact?
  	@thesaurus = Thesaurus.find(params[:id], params[:namespace])
  	render json: @thesaurus.impact
  end

  def impact_report
  	authorize Thesaurus, :impact?
  	results = []
  	thesaurus = Thesaurus.find(params[:id], params[:namespace])
  	results = impact_report_start(thesaurus)
  	respond_to do |format|
      format.pdf do
        @html =Reports::ThesaurusImpactReport.new.create(thesaurus, results, current_user)
        @render_args = {pdf: 'impact_analysis', page_size: current_user.paper_size, lowquality: true}
        render @render_args
      end
    end
  end

  def add_subset
    authorize Thesaurus, :edit?
    results = Thesaurus.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
    thesaurus = Thesaurus.find_minimum(results.first)
    thesaurus = edit_item(thesaurus)
    new_mc = thesaurus.add_subset(the_params[:concept_id])
    AuditTrail.create_item_event(current_user, new_mc, "Subset created.")
    path = edit_subset_thesauri_managed_concept_path(new_mc, source_mc: new_mc.subsets_links.to_id, context_id: params[:ctxt_id])
    render json: { redirect_path: path, }, :status => 200
  end

private

	def impact_report_start(thesaurus)
		initial_results = []
		results = {}
		thesaurus.impact.each do |x|
  		uri = UriV2.new({uri: x})
	  	initial_results += impact_report_node(uri.id, uri.namespace) { |a,b|
  			item = ThesaurusConcept.find(a, b)
  			item.set_parent
  			item
  		}
  	end
  	initial_results.each do |result|
  		if results.has_key?(result[:root].uri)
  			results[result[:root].uri.to_s][:children] += result[:children]
  		else
  			results[result[:root].uri.to_s] = { root: result[:root].to_json, children: result[:children] }
  		end
  	end
  	results.each do |k,v|
  		v[:children] = v[:children].inject([]) do |new_children, item|
  			new_children << { uri: item[:uri].to_s }
  		end
  	end
  	return results
  end

	def impact_report_node(id, namespace)
	  results = []
	  result = {}
	  item = yield(id, namespace)
	  result[:root] = item
	  result[:children] = []
	  results << result
    concepts = IsoConcept.links_to(id, namespace)
    concepts.each do |concept|
      managed_item = IsoManaged.find_managed(concept[:uri].id, concept[:uri].namespace)
		  result[:children] << managed_item
		  uri_s = managed_item[:uri].to_s
      results += impact_report_node(managed_item[:uri].id, managed_item[:uri].namespace) { |a,b|
      	item = IsoManaged.find(a, b, false)
      }
    end
    return results
	end

  def the_params
    #params.require(:thesauri).permit(:identifier, :scope_id, :offset, :count, :label, :concept_id, :reference_ct_id)
    params.require(:thesauri).permit(:identifier, :scope_id, :offset, :count, :label, :concept_id)
  end

end
