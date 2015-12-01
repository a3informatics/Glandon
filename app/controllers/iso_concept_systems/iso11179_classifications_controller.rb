class Iso11179ConceptSystems::Iso11179ClassificationsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @classifications = Iso11179ConceptSystem::Iso11179Classification.all
  end
  
  def new
    @conceptSystem = Iso11179ConceptSystem.find(params[:concept_system_id])
    @classification = Iso11179ConceptSystem::Iso11179Classification.new
  end
  
  def create
    @conceptSystem = Iso11179ConceptSystem.find(params[:concept_system_id])
    @classification = Iso11179ConceptSystem::Iso11179Classification.create(the_params)
    @concept = Iso11179ConceptSystem::Iso11179Concept.create(the_params)
    @conceptSystem.update(@classification, @concept)
    @classification.update(@conceptSystem, @concept)
    @concept.update(@conceptSystem, @classification)
    redirect_to iso11179_concept_system_path(@conceptSystem.id)
  end

  def update
  end

  def edit
  end

  def destroy
    @conceptSystem = Iso11179ConceptSystem.find(params[:concept_system_id])
    @classification = Iso11179ConceptSystem::Iso11179Classification.find(params[:id])
    @concept = Iso11179ConceptSystem::Iso11179Concept.find(@classification.concept_id)
    @classification.destroy()
    @concept.destroy()
    redirect_to iso11179_concept_system_path(@conceptSystem.id)
  end

  def show
    redirect_to classifications_index_path
  end
  
  private
    def the_params
      params.require(:iso11179_concept_system_iso11179_classification).permit(:label, :concept_system_id)
    end
    
end
