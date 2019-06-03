class IsoConceptSystemsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoConceptSystemsController"

  def index
    authorize IsoConceptSystem
    cs_set = IsoConceptSystem.all
    cs = cs_set.empty? ? IsoConceptSystem.create(label: "Tags") : IsoConceptSystem.find(cs_set.first.id, cs_set.first.namespace)
    @concept_systems = cs.to_json
    @concept_systems[:children] =[]
    cs.children.each do |child|
      @concept_systems[:children] << child.to_json
    end
  end

  def add
    authorize IsoConceptSystem, :create?
    conceptSystem = IsoConceptSystem.find(params[:id], params[:namespace])
    node = conceptSystem.add(the_params)
    if node.errors.blank?
      flash[:success] = 'Concept system node was successfully created.'
    else
      flash[:error] = "Concept system node was not created. #{node.errors.full_messages.to_sentence}."
    end
    redirect_to iso_concept_systems_path
  end

private

    def the_params
      params.require(:iso_concept_system).permit(:label, :description)
    end
    
end
