class IsoConceptSystemsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoConceptSystemsController"

  def index
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

  def new
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.new
  end
  
  def create
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.create(the_params)
    if @conceptSystem.errors.blank?
      flash[:success] = 'Concept system was successfully created.'
    else
      flash[:error] = "Concept system was not created. #{@conceptSystem.errors.full_messages.to_sentence}."
    end
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
    node = conceptSystem.add(the_params)
    if node.errors.blank?
      flash[:success] = 'Concept system node was successfully created.'
    else
      flash[:error] = "Concept system node was not created. #{node.errors.full_messages.to_sentence}."
    end
    redirect_to iso_concept_system_path(:id => conceptSystem.id, :namespace => conceptSystem.namespace)
  end

  def destroy
    authorize IsoConceptSystem
    concept_system = IsoConceptSystem.find(params[:id], params[:namespace])
    if concept_system.children.length == 0
      concept_system.destroy
      flash[:success] = 'Concept system node was successfully deleted.'
    else
      flash[:error] = "Child tags exist, this cannot be deleted."
    end
    redirect_to iso_concept_systems_path(:id => params[:parent_id], :namespace => params[:parent_namespace])
  end

  def show
    authorize IsoConceptSystem
    @conceptSystem = IsoConceptSystem.find(params[:id], params[:namespace])
  end
  
  
private

    def the_params
      params.require(:iso_concept_system).permit(:label, :description)
    end
    
end
