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
  end
  
  def history
    authorize Thesaurus
    @identifier = params[:identifier]
    @thesauri = Thesaurus.history(params)
  end
  
  def create
    authorize Thesaurus
    @thesaurus = Thesaurus.create_simple(the_params)
    #ConsoleLogger::log(C_CLASS_NAME, "create","TH=(#{@thesaurus.to_json})")
    #ConsoleLogger::log(C_CLASS_NAME, "create","TH=(#{@thesaurus.errors.to_json})")
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
    @thesaurus = Thesaurus.find(params[:id], params[:namespace])
    if @thesaurus.new_version?
      th = Thesaurus.find_complete(params[:id], params[:namespace])
      json = th.to_operation
      new_th = Thesaurus.create(json)
      @thesaurus = Thesaurus.find(new_th.id, new_th.namespace)
    end
  end

  def add_child
    authorize Thesaurus, :create?
    thesaurus = Thesaurus.find(params[:id], params[:namespace], false)
    thesaurus_concept = thesaurus.add_child(params[:children][0])
    if thesaurus_concept.errors.empty?
      AuditTrail.update_item_event(current_user, thesaurus, "Terminology updated. Item #{thesaurus_concept.identifier} added.")
      render :json => thesaurus_concept.to_json, :status => 200
    else
      render :json => {:errors => thesaurus_concept.errors.full_messages}, :status => 422
    end
  end

  def destroy
    authorize Thesaurus
    thesaurus = Thesaurus.find(params[:id], params[:namespace])
    thesaurus.destroy
    AuditTrail.delete_item_event(current_user, thesaurus, "Terminology deleted.")
    redirect_to thesauri_index_path
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
  end

  def search
    authorize Thesaurus, :view?
    @thesaurus = Thesaurus.find(params[:id], params[:namespace], false)
    @items = Notepad.where(user_id: current_user).find_each
  end
  
  def next
    authorize Thesaurus, :view?
    id = params[:id]
    namespace = params[:namespace]
    @cdiscTerm = Thesaurus.find(id, namespace, false)
    items = []
    more = true
    offset = params[:offset].to_i
    limit = params[:limit].to_i
    #ConsoleLogger::log(C_CLASS_NAME,"next","Offset=" + offset.to_s + ", limit=" + limit.to_s)  
    items = Thesaurus.next(offset, limit, namespace)
    if items.count < limit
      more = false
    end
    results = {}
    results[:offset] = offset + items.count
    results[:limit] = limit
    results[:more] = more
    results[:data] = items
    ConsoleLogger::log(C_CLASS_NAME,"next","Offset=" + results[:offset].to_s + ", limit=" + results[:limit].to_s + ", count=" + items.count.to_s)  
    render :json => results, :status => 200
  end

   def export_ttl
    authorize Thesaurus
    item = IsoManaged::find(params[:id], params[:namespace])
    send_data to_turtle(item.triples), filename: "#{item.owner}_#{item.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
private

  def the_params
    params.require(:thesaurus).permit(:identifier, :version, :versionLabel, :label, :namespace_id, :namespace, :data)
  end
    
end
