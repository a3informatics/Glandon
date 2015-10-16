class Iso11179ConceptSystemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @conceptSystems = Iso11179ConceptSystem.all
  end
  
  def new
    @conceptSystem = Iso11179ConceptSystem.new
  end
  
  def create
    @conceptSystem = Iso11179ConceptSystem.create(the_params)
    redirect_to iso11179_concept_systems_path
  end

  def update
  end

  def edit
  end

  def destroy
    @conceptSystem = Iso11179ConceptSystem.find(params[:id])
    @conceptSystem.destroy()
    redirect_to iso11179_concept_systems_path
  end

  def show
    @classifications = Hash.new
    @conceptSystem = Iso11179ConceptSystem.find(params[:id])
    @conceptSystem.classifications.each do |key, value|
      @classifications[key] = Iso11179ConceptSystem::Iso11179Classification.find(value)
    end
  end
  
  private
    def the_params
      params.require(:iso11179_concept_system).permit(:notation)
    end
    
end
