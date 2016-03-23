class IsoConceptSystemsController < ApplicationController
  
  before_action :authenticate_user!
  
  def index
    authorize IsoConceptSystem
    @conceptSystems = IsoConceptSystem.all
  end

  def new
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.new
  end
  
  def create
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.create(the_params)
    redirect_to iso_concept_systems_path
  end

  def node_new
    authorize IsoConceptSystem, :create?
    @id = params[:id]
    @node = IsoConceptSystem::Node.new
  end

  def node_add
    authorize IsoConceptSystem, :create?
    @node = IsoConceptSystem::Node.create(the_params)
    @conceptSystem = IsoConceptSystem.find(params[:id])
    @conceptSystem.add(@node)
    redirect_to iso_concept_system_path(@conceptSystem)
  end

  def destroy
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.find(params[:id])
    @conceptSystem.destroy()
    redirect_to iso_concept_systems_path
  end

  def show
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.find(params[:id])
  end
  
  private
    def the_params
      params.require(:iso_concept_system).permit(:identifier, :label, :notation, :definition)
    end
    
end
