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
    identifier = params[:identifier]
    @thesaurus = Thesaurus.create(the_params)
    redirect_to thesauri_index_path
  end

  def update
    authorize Thesaurus
    id = params[:id]
    namespace = params[:namespace]
    data = params[:data]
    @thesaurus = Thesaurus.find(id,namespace)
    @thesaurus.update(params)
    if @thesaurus.errors.empty?
      @thesaurus = Thesaurus.find(id,namespace)
      render json: @thesaurus.d3
    else
      render :json => { :errors => @thesaurus.errors.full_messages}, :status => 422
    end
  end

  def edit
    authorize Thesaurus
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id,namespace)
  end

  def destroy
    authorize Thesaurus
    @thesaurus = Thesaurus.find(params[:id])
    @thesaurus.destroy()
    redirect_to thesauri_index_path
  end

  def show
    authorize Thesaurus
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id, namespace)
  end
  
  def view
    authorize Thesaurus
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id, namespace)
  end

  def search
    authorize Thesaurus, :view?
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id, namespace, false)
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
    id = params[:id]
    namespace = params[:namespace]
    item = IsoManagedNew::find(id, namespace)
    send_data to_turtle(item.triples), filename: "#{item.owner}_#{item.identifier}.ttl", type: 'application/x-turtle', disposition: 'inline'
  end
  
private

  def the_params
    params.require(:thesaurus).permit(:identifier, :version, :versionLabel, :label, :namespace_id, :namespace, :data)
  end
    
end
