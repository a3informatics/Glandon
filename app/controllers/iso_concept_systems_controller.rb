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
    @namespace = params[:namespace]
    @node = IsoConceptSystem::Node.new
  end

  def node_add
    authorize IsoConceptSystem, :create?
    conceptSystem = IsoConceptSystem.find(params[:id], params[:namespace])
    conceptSystem.add(the_params)
    redirect_to iso_concept_system_path(:id => conceptSystem.id, :namespace => conceptSystem.namespace)
  end

  def destroy
    authorize IsoConceptSystem
    concept_system = IsoConceptSystem.find(params[:id], params[:namespace])
    if concept_system.children.length == 0
      concept_system.destroy()
    else
      flash[:error] = "Child tags exist, this cannot be deleted."
    end
    redirect_to iso_concept_systems_path(:id => params[:parent_id], :namespace => params[:parent_namespace])
  end

  def show
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.find(params[:id], params[:namespace])
  end
  
  def view
    authorize IsoConceptSystem
    @concept_systems = Hash.new
    @concept_systems[:label] = "Root"
    @concept_systems[:children] = Array.new
    cs_set = IsoConceptSystem.all
    cs_set.each do |cs|
      concept_system = IsoConceptSystem.find(cs.id, cs.namespace)
      @concept_systems[:children] << concept_system.to_json
    end
  end
  
private

    def the_params
      params.require(:iso_concept_system).permit(:label, :description)
    end
    
end
