class IsoConceptSystemsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoConceptSystemsController"

  def index
    authorize IsoConceptSystem
    @concept_system = IsoConceptSystem.root
  end

  def show
    authorize IsoConceptSystem
    concept_system = IsoConceptSystem.find(params[:id], params[:namespace])
    render :json => {data: concept_system.to_json}, :status => 200
  end    

  def add
    authorize IsoConceptSystem, :create?
    conceptSystem = IsoConceptSystem.find(params[:id], params[:namespace])
    node = conceptSystem.add(the_params)
    status = node.errors.empty? ? 200 : 400
    render :json => {errors: node.errors.full_messages}, :status => status
  end

private

  def the_params
    params.require(:iso_concept_system).permit(:label, :description)
  end
    
end
