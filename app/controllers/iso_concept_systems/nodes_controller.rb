class IsoConceptSystems::NodesController < ApplicationController
  
  before_action :authenticate_user!
  
  def node_new
    authorize IsoConceptSystem::Node, :create?
    @id = params[:id]
    @namespace = params[:namespace]
    @node = IsoConceptSystem::Node.new
  end

  def node_add
    authorize IsoConceptSystem::Node, :create?
    node = IsoConceptSystem::Node.find(params[:id], params[:namespace])
    new_node = node.add(the_params)
    if new_node.errors.blank?
      flash[:success] = 'Concept system node was successfully created.'
    else
      flash[:error] = "Concept system node was not created. #{new_node.errors.full_messages.to_sentence}."
    end
    redirect_to iso_concept_systems_node_path(:id => node.id, :namespace => node.namespace)
  end

  def destroy
    authorize IsoConceptSystem::Node
    node = IsoConceptSystem::Node.find(params[:id], params[:namespace])
    if node.children.length == 0
      node.destroy
      flash[:success] = 'Concept system node was successfully deleted.'
    else
      flash[:error] = "Child tags exist, this cannot be deleted."
    end
    redirect_to iso_concept_systems_node_path(:id => params[:parent_id], :namespace => params[:parent_namespace])
  end

  def show
    authorize IsoConceptSystem::Node
    @node = IsoConceptSystem::Node.find(params[:id], params[:namespace])
  end
  
private

    def the_params
      params.require(:iso_concept_systems_node).permit(:label, :description)
    end

end
