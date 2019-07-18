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
        redirect_to thesauri_index_path if results.count == 0
        @thesauri_id = results.first
        @identifier = the_params[:identifier]
        @scope_id = the_params[:scope_id]
      end
      format.json do
        results = []
        history_results = Thesaurus.history_pagination(identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id]), count: the_params[:count], offset: the_params[:offset])
        history_results.each do |object|
          results << object.to_h.reverse_merge!(add_history_paths(:thesauri, object))
        end
        render json: {data: results, offset: the_params[:offset].to_i, count: results.count}
      end
    end
  end
  
  def show
    authorize Thesaurus
start = Time.now
    @ct = Thesaurus.find(params[:id])
s1 = Time.now
    respond_to do |format|
      format.html do
        @close_path = request.referer
puts "Thesauri Show S1: #{s1-start}"
      end
      format.json do
        results = []
        children = @ct.managed_children_pagination({offset: params[:offset], count: params[:count]})
s2 = Time.now
        children.each {|c| results << c.to_h.reverse_merge!({show_path: thesauri_managed_concept_path(c)})}
s3 = Time.now
        render json: {data: results, offset: params[:offset].to_i, count: results.count}, status: 200
puts "Thesauri Show S1: #{s1-start}"
puts "Thesauri Show S2: #{s2-s1}"
puts "Thesauri Show S3: #{s3-s2}"
      end
    end
s4 = Time.now
puts "Thesari Show Overall: #{s4-start}"
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
    @thesaurus = Thesaurus.find(params[:id], params[:namespace], false)
    @token = get_token(@thesaurus)
    if @thesaurus.new_version?
      th = Thesaurus.find_complete(params[:id], params[:namespace])
      new_th = Thesaurus.create(th.to_operation)
      @thesaurus = Thesaurus.find(new_th.id, new_th.namespace, false)
      @token.release
	    @token = get_token(@thesaurus)
	  end
  	@close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.scope.id)
    @tc_identifier_prefix = ""
  end

  def children
    authorize Thesaurus, :edit?
    results = []
    thesaurus = Thesaurus.find(params[:id], params[:namespace])
    thesaurus.children.each do |child|
      results << child.to_json
    end
    render :json => { data: results }, :status => 200
  end

  def add_child
    authorize Thesaurus, :create?
    thesaurus = Thesaurus.find(params[:id], params[:namespace], false)
    token = Token.find_token(thesaurus, current_user)
    if !token.nil?
      thesaurus_concept = thesaurus.add_child(the_params)
      if thesaurus_concept.errors.empty?
        AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated.") if token.refresh == 1
        render :json => thesaurus_concept.to_json, :status => 200
      else
        render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
      end
    else
      render :json => {:errors => ["The changes were not saved as the edit lock has timed out."]}, :status => 422
    end
  end

  def destroy
    authorize Thesaurus
    thesaurus = Thesaurus.find(params[:id], params[:namespace])
    token = Token.obtain(thesaurus, current_user)
    if !token.nil?
      thesaurus.destroy
      AuditTrail.delete_item_event(current_user, thesaurus, "Terminology deleted.")
      token.release
    else
      flash[:error] = "The item is locked for editing by another user."
    end
    redirect_to request.referer
  end

  def view
    authorize Thesaurus
    @thesaurus = Thesaurus.find(params[:id], params[:namespace])
    @close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.scope.id)
  end

  def search
    authorize Thesaurus, :view?
    @thesaurus = Thesaurus.find(params[:id], false)
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
    params.require(:thesauri).permit(:identifier, :scope_id, :offset, :count)
    #(:id, :namespace, :label, :identifier, :scope_id, :notation, :synonym, :definition, :preferredTerm, :type)
  end
    
end
