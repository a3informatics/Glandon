class ThesauriController < ApplicationController
  
  C_CLASS_NAME = "ThesauriController"

  before_action :authenticate_user!
  
  def new
    @thesaurus = Thesaurus.new
  end

  def index
    @thesauri = Thesaurus.unique
  end
  
  def history
    @identifier = params[:identifier]
    @thesauri = Thesaurus.history(params)
  end
  
  def create
    identifier = params[:identifier]
    @thesaurus = Thesaurus.create(the_params)
    redirect_to thesauri_index_path
  end

  def update
    id = params[:id]
    namespace = params[:namespace]
    data = params[:data]
    @thesaurus = Thesaurus.find(id,namespace)
    @thesaurus.update(params)
    if @thesaurus.errors.empty?
      @thesaurus = Thesaurus.find(id,namespace)
      render json: @thesaurus.to_D3
    else
      render :json => { :errors => @thesaurus.errors.full_messages}, :status => 422
    end
  end

  def edit
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id,namespace)
  end

  def destroy
    @thesaurus = Thesaurus.find(params[:id])
    @thesaurus.destroy()
    redirect_to thesauri_index_path
  end

  def show
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id, namespace)
  end
  
  def view
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id, namespace)
  end

  def search
    id = params[:id]
    namespace = params[:namespace]
    @thesaurus = Thesaurus.find(id, namespace, false)
  end
  
  def searchOld
    term = params[:term]
    textSearch = params[:textSearch]
    cCodeSearch = params[:cCodeSearch]
    if term != "" && textSearch == "text"
      @results = SponsorTerm.searchText(term)  
    elsif term != "" && cCodeSearch == "ccode"
      @results = SponsorTerm.searchIdentifier(term)
    else
      @results = Array.new
    end
    render json: @results
  end

  def searchNew
    id = params[:id]
    ns = params[:namespace]
    offset = params[:start]
    length = params[:length]
    draw = params[:draw].to_i
    search = params[:search]
    searchTerm = search[:value]
    order = params[:order]["0"]
    col = order[:column]
    dir = order[:dir]
    count = Thesaurus.count(searchTerm, ns)
    items = Thesaurus.search(offset, length, col, dir, searchTerm, ns)
    @results = {
      :draw => draw.to_s,
      :recordsTotal => length.to_s,
      :recordsFiltered => count.to_s,
      :data => items }
    render json: @results
  end 

private

  def the_params
    params.require(:thesaurus).permit(:identifier, :version, :versionLabel, :label, :namespace_id, :namespace, :data)
  end
    
end
