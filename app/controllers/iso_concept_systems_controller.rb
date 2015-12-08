class IsoConceptSystemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    @conceptSystems = IsoConceptSystem.all
  end

  def new
    @conceptSystem = IsoConceptSystem.new
  end
  
  def create
    @conceptSystem = IsoConceptSystem.create(the_params)
    redirect_to iso_concept_systems_path
  end

  def node_new
    @id = params[:id]
    @node = IsoConceptSystem::Node.new
  end

  def node_add
    @node = IsoConceptSystem::Node.create(the_params)
    @conceptSystem = IsoConceptSystem.find(params[:id])
    @conceptSystem.add(@node)
    redirect_to iso_concept_system_path(@conceptSystem)
  end

  def destroy
    @conceptSystem = IsoConceptSystem.find(params[:id])
    @conceptSystem.destroy()
    redirect_to iso_concept_systems_path
  end

  def show
    @conceptSystem = IsoConceptSystem.find(params[:id])
  end
  
  private
    def the_params
      params.require(:iso_concept_system).permit(:identifier, :label, :notation, :definition)
    end
    
end
