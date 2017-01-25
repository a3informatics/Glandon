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
    @thesauri = Thesaurus.history(params)
    redirect_to thesauri_index_path if @thesauri.count == 0
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
    if @thesaurus.new_version?
      th = Thesaurus.find_complete(params[:id], params[:namespace])
      json = th.to_operation
      new_th = Thesaurus.create(json)
      @thesaurus = Thesaurus.find(new_th.id, new_th.namespace, false)
    end
    @token = Token.obtain(@thesaurus, current_user)
    @close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.owner_id)
    @tc_identifier_prefix = ""
    if @token.nil?
      flash[:error] = "The item is locked for editing by another user."
      redirect_to request.referer
    end
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

  def show
    authorize Thesaurus
    @thesaurus = Thesaurus.find(params[:id], params[:namespace])
    respond_to do |format|
      format.html
      format.json do
        results = @thesaurus.to_json
        render json: results
      end
    end
  end
  
  def view
    authorize Thesaurus
    @thesaurus = Thesaurus.find(params[:id], params[:namespace])
    @close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.owner_id)
  end

  def search
    authorize Thesaurus, :view?
    @thesaurus = Thesaurus.find(params[:id], params[:namespace], false)
    @items = Notepad.where(user_id: current_user).find_each
    @close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.owner_id)
  end
  
  def search_current
    authorize Thesaurus, :view?
    @items = Notepad.where(user_id: current_user).find_each
    @close_path = thesauri_index_path
  end
  
  #def search_new
  #  authorize Thesaurus, :view?
  #  @thesaurus = Thesaurus.find(params[:id], params[:namespace], false)
  #  @items = Notepad.where(user_id: current_user).find_each
  #  @close_path = history_thesauri_index_path(identifier: @thesaurus.identifier, scope_id: @thesaurus.owner_id)
  #end
  
  def search_results
    authorize Thesaurus, :view?
    count = Thesaurus.count(params)
    items = Thesaurus.search_new(params)
    @results = {
      :draw => params[:draw],
      :recordsTotal => params[:length],
      :recordsFiltered => count.to_s,
      :data => items }
    render json: @results
  end

=begin  
  def next
    authorize Thesaurus, :view?
    id = params[:id]
    namespace = params[:namespace]
    @cdiscTerm = Thesaurus.find(id, namespace, false)
    items = []
    more = true
    offset = params[:offset].to_i
    limit = params[:limit].to_i
    items = Thesaurus.next(offset, limit, namespace)
    if items.count < limit
      more = false
    end
    results = {}
    results[:offset] = offset + items.count
    results[:limit] = limit
    results[:more] = more
    results[:data] = items
    render :json => results, :status => 200
  end
=end

   def export_ttl
    authorize Thesaurus
    item = IsoManaged::find(params[:id], params[:namespace])
    send_data to_turtle(item.triples), filename: "#{item.owner}_#{item.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
private

  def the_params
    params.require(:thesauri).permit(:id, :namespace, :label, :identifier, :notation, :synonym, :definition, :preferredTerm, :type)
  end
    
end
