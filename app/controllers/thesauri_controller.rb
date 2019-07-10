class ThesauriController < ApplicationController
  
  C_CLASS_NAME = "ThesauriController"

  before_action :authenticate_user!
  
  def new
    authorize Thesaurus
    @thesaurus = Thesaurus.new
  end

  def index
    authorize Thesaurus
    @thesauri = Thesaurus.unique
    respond_to do |format|
      format.html 
      format.json do
        results = {}
        results[:data] = []
        @thesauri.each do |item|
          results[:data] << item
        end
        render json: results
      end
    end
  end
  
  def history
    authorize Thesaurus
    @identifier = params[:identifier]
    #@scope_id = params[:scope_id]
    @thesauri = Thesaurus.history({identifier: the_params[:identifier], scope: IsoNamespace.find(the_params[:scope_id])})
    redirect_to thesauri_index_path if @thesauri.count == 0
  end
  
  def show
    authorize Thesaurus
    @ct = CdiscTerm.find(params[:id])
  end
  
  def show_results
start = Time.now()
    results = []
    authorize Thesaurus, :show?
    @ct = Thesaurus.find(params[:id])
step1 = Time.now()
    children = @ct.managed_children_pagination({offset: params[:offset], count: params[:count]})
step2 = Time.now()
    children.each {|c| results << c.to_h}
step3 = Time.now()
    render json: {data: results, offset: params[:offset].to_i, count: results.count}, status: 200
step4 = Time.now()
puts "1=#{(step1 - start).round(2)} secs"
puts "2=#{(step2 - start).round(2)} secs"
puts "3=#{(step3 - start).round(2)} secs"
puts "4=#{(step4 - start).round(2)} secs"
  end

  def create
    authorize Thesaurus
    @thesaurus = Thesaurus.create_simple(the_params)
    if @thesaurus.errors.empty?
      AuditTrail.create_item_event(current_user, @thesaurus, "Terminology created.")
      flash[:success] = 'Terminology was successfully created.'
      redirect_to thesauri_index_path
    else
      flash[:error] = @thesaurus.errors.full_messages.to_sentence
      redirect_to new_thesauri_path
    end
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
    @thesaurus = Thesaurus.find(params[:id], params[:namespace], false)
    #@items = Notepad.where(user_id: current_user).find_each
    @close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.owner_id)
  end
  
  def search_current
    authorize Thesaurus, :view?
    #@items = Notepad.where(user_id: current_user).find_each
    @close_path = thesauri_index_path
  end
  
  def search_results
    authorize Thesaurus, :view?
    if Thesaurus.empty_search?(params)
      render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => "0", :data => [] }
    else
      results = Thesaurus.search(params)
      render json: { :draw => params[:draw], :recordsTotal => params[:length], :recordsFiltered => results[:count].to_s, :data => results[:items] }
    end
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
    params.require(:thesauri).permit(:id, :namespace, :label, :identifier, :scope_id, :notation, :synonym, :definition, :preferredTerm, :type)
  end
    
end
