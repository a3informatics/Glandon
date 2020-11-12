class IsoConceptSystemsController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoConceptSystemsController"

  def index
    authorize IsoConceptSystem
    @concept_system = IsoConceptSystem.root
  end

  def show
    authorize IsoConceptSystem
    concept_system = IsoConceptSystem.root
    result = concept_system.find_all
    render :json => {data: result.to_h}, :status => 200
  end    

  def add
    authorize IsoConceptSystem, :create?
    concept_system = IsoConceptSystem.find(protect_from_bad_id(params))
    node = concept_system.add(the_params)
    status = node.errors.empty? ? 200 : 400
    render :json => {errors: node.errors.full_messages}, :status => status
  end

  def destroy
    authorize IsoConceptSystem
    render :json => {errors: ["You are not permitted to delete the root tag"]}, :status => 200
  end

private

  def the_params
    params.require(:iso_concept_system).permit(:label, :description)
  end
    
end
