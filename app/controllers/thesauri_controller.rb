class ThesauriController < ApplicationController
  
  C_CLASS_NAME = "ThesauriController"

  before_action :authenticate_user!
  
  def index
    @thesauri = Thesaurus.all
  end
  
  def new
    @thesaurus = Thesaurus.new
  end
  
  def create
    identifier = params[:identifier]
    @thesaurus = Thesaurus.createLocal(the_params)
    redirect_to thesauri_index_path
  end

  def update
    id = params[:id]
    namespace = params[:namespace]
    data = params[:data]
    ConsoleLogger::log(C_CLASS_NAME,"ThesauriController","id=" + id + ", namespace=" + namespace + ", data=" + data.to_s)
    @thesaurus = Thesaurus.find(id,namespace)
    ConsoleLogger::log(C_CLASS_NAME,"ThesauriController","*****Back*****")
    @thesaurus.update(params)
    @thesaurus = Thesaurus.find(id,namespace)
    render json: @thesaurus.to_D3
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
    @thesaurus = Thesaurus.find(id,namespace)
  end
  
private

  def the_params
    params.require(:thesaurus).permit(:identifier, :version, :versionLabel, :label, :namespace_id, :namespace, :data)
  end
    
end
