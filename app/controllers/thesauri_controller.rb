class ThesauriController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @thesauri = Thesaurus.all
  end
  
  def new
    @thesaurus = Thesaurus.new
  end
  
  def create
    @thesaurus = Thesaurus.create(the_params)
    redirect_to thesauri_index_path
  end

  def update
  end

  def edit
  end

  def destroy
     @thesaurus = Thesaurus.find(params[:id])
     @thesaurus.destroy
     redirect_to thesauri_index_path
  end

  def show
    redirect_to thesauri_index_path
  end
  
  private
    def the_params
      params.require(:thesaurus).permit(:ii_id)
    end
    
end
