class BiomedicalConceptTemplatesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @bcts = BiomedicalConceptTemplate.all
  end
  
  def new
  end
  
  def create
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def show 
    id = params[:id]
    namespace = params[:namespace]
    @bct = BiomedicalConceptTemplate.find(id, namespace)
  end
  
private
  def the_params
    params.require(:bct).permit()
  end  
end
