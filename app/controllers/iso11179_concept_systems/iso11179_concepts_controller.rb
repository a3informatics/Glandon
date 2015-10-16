class Iso11179ConceptSystems::Iso11179ConceptsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @concepts = Iso11179ConceptSystem::Iso11179Concept.all
  end
  
  def new
    @concept = Iso11179ConceptSystem::Iso11179Concept.new
  end
  
  def create
    @concept = Iso11179ConceptSystem::Iso11179Concept.create(the_params)
    redirect_to concepts_index_path
  end

  def update
  end

  def edit
  end

  def destroy
    @concept = Iso11179ConceptSystem::Iso11179Concept.find(params[:id])
    @concept.destroy()
    redirect_to concepts_index_path
  end

  def show
    redirect_to concepts_index_path
  end
  
  private
    def the_params
      params.require(:iso11179_concept_system_iso11179_concept).permit(:iso11179_concept_system)
    end
    
end
