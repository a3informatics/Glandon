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
      format.html 
      format.json do
        render json: {data: @thesauri}
      end
    end
  end
  
  def history
    authorize Thesaurus
    respond_to do |format|
      format.html do
        results = Thesaurus.history_uris(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]))
        if results.empty? 
          redirect_to thesauri_index_path 
        else
          @thesauri_id = results.first.to_id
          @identifier = the_params[:identifier]
          @scope_id = the_params[:scope_id]
        end
      end
      format.json do
        results = []
        history_results = Thesaurus.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        results = add_history_paths(Thesaurus, :thesauri, history_results)
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end
  
  def show
    authorize Thesaurus
    @ct = Thesaurus.find_minimum(params[:id])
    respond_to do |format|
      format.html do
        @close_path = request.referer
      end
      format.json do
        results = []
        children = @ct.managed_children_pagination({offset: params[:offset], count: params[:count]})
        children.each {|c| results << c.reverse_merge!({show_path: thesauri_managed_concept_path(c[:id])})}
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
    @token = get_token(@thesaurus)
    if @thesaurus.new_version?
      th = Thesaurus.find_complete(params[:id], params[:namespace])
      new_th = Thesaurus.create(th.to_operation)
      @thesaurus = Thesaurus.find(new_th.id, new_th.namespace, false)
      @token.release
	    @token = get_token(@thesaurus)
	  end
  	@close_path = history_thesauri_index_path({thesauri: {identifier: @thesaurus.scoped_identifier, scope_id: @thesaurus.scope}})
    @parent_identifier = ""
  end

  def children
    authorize Thesaurus, :edit?
    results = []
    ct = Thesaurus.find_minimum(params[:id])
    children = ct.managed_children_pagination({offset: "0", count: "10000"})
    children.each {|c| results << c.reverse_merge!({edit_path: edit_thesauri_managed_concept_path(c[:id]), delete_path: thesauri_managed_concept_path(c[:id])})}
    render :json => { data: results }, :status => 200
  end

  def add_child
    authorize Thesaurus, :create?
    thesaurus = Thesaurus.find_minimum(params[:id])
    token = Token.find_token(thesaurus, current_user)
    if !token.nil?
      thesaurus_concept = thesaurus.add_child(the_params)
      if thesaurus_concept.errors.empty?
        AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated.") if token.refresh == 1
        result = thesaurus_concept.simple_to_h
        result.reverse_merge!({edit_path: edit_thesauri_managed_concept_path(thesaurus_concept), delete_path: thesauri_managed_concept_path(thesaurus_concept)})
        render :json => {data: thesaurus_concept.simple_to_h}, :status => 200
      else
        render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
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
    authorize Thesaurus, :view?
    @thesaurus = Thesaurus.find_minimum(params[:id])
    respond_to do |format|
      format.html 
        @close_path = history_thesauri_index_path(thesauri: {identifier: @thesaurus.identifier, scope_id: @thesaurus.owner})
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
  
  def changes
    authorize CdiscTerm, :view?
    respond_to do |format|
      format.html do
        @version_count = current_user.max_term_display.to_i
        @ct = Thesaurus.find_minimum(params[:id])
        link_objects = @ct.forward_backward(1, current_user.max_term_display.to_i)
        @links = {}
        link_objects.each {|k,v| @links[k] = v.nil? ? "" : changes_thesauri_path(v.to_id)}
        @close_path = request.referer #history_thesauri_index_path(thesauri: {identifier: @ct.identifier, scope_id: @ct.owner})
      end
      format.json do
        ct = Thesaurus.find_minimum(params[:id])
        cls = ct.changes(current_user.max_term_display.to_i)
        cls[:items].each do |k,v| 
          v[:changes_path] = changes_thesauri_managed_concept_path(v[:id])
        end
        render json: {data: cls}
      end
    end
  end

  def changes_report
    authorize CdiscTerm, :view?
    ct = Thesaurus.find_minimum(params[:id])
    cls = ct.changes(current_user.max_term_display.to_i)
    respond_to do |format|
      format.pdf do
        @html = Reports::CdiscChangesReport.new.create(cls, current_user)
        render pdf: "terminology_changes.pdf", page_size: current_user.paper_size, orientation: 'Landscape', lowquality: true
      end
    end
  end

  def submission
    authorize CdiscTerm, :view?
    respond_to do |format|
      format.html do
        @version_count = current_user.max_term_display.to_i
        @ct = Thesaurus.find_minimum(params[:id])
        link_objects = @ct.forward_backward(1, current_user.max_term_display.to_i)
        @links = {}
        link_objects.each {|k,v| @links[k] = v.nil? ? "" : submission_thesauri_path(v.to_id)}
        @close_path = request.referer
      end
      format.json do
        ct = Thesaurus.find_minimum(params[:id])
        cls = ct.submission(current_user.max_term_display.to_i)
        render json: {data: cls}
      end
    end
  end

  def submission_report
    authorize CdiscTerm, :view?
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

  def search_current
    authorize Thesaurus, :view?
    @close_path = thesauri_index_path
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
    params.require(:thesauri).permit(:identifier, :scope_id, :offset, :count, :label)
    #(:id, :namespace, :label, :identifier, :scope_id, :notation, :synonym, :definition, :preferredTerm, :type)
  end
    
end
