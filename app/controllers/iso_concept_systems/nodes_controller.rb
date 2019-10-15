class IsoConceptSystems::NodesController < ApplicationController
  
  before_action :authenticate_user!
  
  def add
    authorize IsoConceptSystem::Node, :create?
    node = IsoConceptSystem::Node.find(params[:id])
    new_node = node.add(the_params)
    status = new_node.errors.empty? ? 200 : 400
    render :json => {errors: new_node.errors.full_messages}, :status => status
  end

  def destroy
    authorize IsoConceptSystem::Node
    node = IsoConceptSystem::Node.find(params[:id])
    node.delete
    status = node.errors.empty? ? 200 : 500
    render :json => {errors: node.errors.full_messages}, :status => status
  rescue => e
    render :json => {errors: ["Something went wrong deleting the tag."]}, :status => 500
  end

  def update
    authorize IsoConceptSystem::Node
    node = IsoConceptSystem::Node.find(params[:id])
    node.update(the_params)
    status = node.errors.empty? ? 200 : 400
    render :json => {errors: node.errors.full_messages}, :status => status
  rescue => e
    render :json => {errors: ["Something went wrong updating the tag."]}, :status => 500
  end
  
private

  def the_params
    params.require(:iso_concept_systems_node).permit(:label, :description)
  end

end
