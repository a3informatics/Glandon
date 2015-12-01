class IsoConceptSystems::NodesController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @concepts = IsoConceptSystem::Node.all
  end
  
  def new
    @concept = IsoConceptSystem::Node.new
  end
  
  def create
    @concept = IsoConceptSystem::Node.create(the_params)
    redirect_to iso_concept_systems_path
  end

  def update
  end

  def edit
  end

  def destroy
    @concept = IsoConceptSystem::Node.find(params[:id])
    @concept.destroy()
    redirect_to iso_concept_systems_path
  end

  def show
    redirect_to iso_concept_systems_path
  end
  
  private
    def the_params
      params.require(:iso_concept_systems_node).permit(:identifier, :definition, :label)
    end
    
end
