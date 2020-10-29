class IsoConceptSystems::NodesController < ApplicationController

  before_action :authenticate_user!

  def add
    authorize IsoConceptSystem::Node, :create?
    node = IsoConceptSystem::Node.find(params[:id])
    new_node = node.add(the_params)
    if new_node.errors.empty?
      render :json => { data: new_node.to_h }, :status => 200
    else
      render :json => { errors: new_node.errors.full_messages }, :status => 422
    end
  end

  def destroy
    authorize IsoConceptSystem::Node
    node = IsoConceptSystem::Node.find(params[:id])
    node.delete
    if node.errors.empty?
      render :json => { }, :status => 200
    else
      render :json => { errors: node.errors.full_messages }, :status => 422
    end
    rescue => e
      render :json => {errors: ["Something went wrong deleting the tag."]}, :status => 500
  end

  def update
    authorize IsoConceptSystem::Node
    node = IsoConceptSystem::Node.find(params[:id])
    node.update(the_params)

    if node.errors.empty?
      render :json => { data: node.to_h }, :status => 200
    else
      render :json => { errors: node.errors.full_messages }, :status => 422
    end
    rescue => e
      render :json => { errors: ["Something went wrong updating the tag."] }, :status => 500
  end

private

  def the_params
    params.require(:iso_concept_systems_node).permit(:label, :description)
  end

end
