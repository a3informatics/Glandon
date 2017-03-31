class IsoConceptSystems::NodesController < ApplicationController
  
  before_action :authenticate_user!
  
  def node_new
    authorize IsoConceptSystem::Node, :create?
    @id = params[:id]
    @namespace = params[:namespace]
    @node = IsoConceptSystem::Node.new
    @parent_node = IsoConceptSystem::Node.find(@id, @namespace)
    @parent_node_path = iso_concept_systems_node_path(:id => @id, :namespace => @namespace)
    uri = IsoConceptSystem::Node.find_system(@id, @namespace)
    @concept_system = IsoConceptSystem.find(uri.id, uri.namespace)
    @concept_system_path = iso_concept_system_path(:id => @concept_system.id, :namespace => @concept_system.namespace)
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
    @node_path = iso_concept_systems_node_path(:id => @node.id, :namespace => @node.namespace)
    uri = IsoConceptSystem::Node.find_system(@node.id, @node.namespace)
    @concept_system = IsoConceptSystem.find(uri.id, uri.namespace)
    @concept_system_path = iso_concept_system_path(:id => @concept_system.id, :namespace => @concept_system.namespace)
    uri = IsoConceptSystem::Node.find_parent(@node.id, @node.namespace)
    if !uri.nil?
      @parent_node = IsoConceptSystem::Node.find(uri.id, uri.namespace)
      @parent_node_path = iso_concept_systems_node_path(:id => @parent_node.id, :namespace => @parent_node.namespace)
    else
      @parent_node = nil
      @parent_node_path = ""      
    end
  end
  
private

    def the_params
      params.require(:iso_concept_systems_node).permit(:label, :description)
    end

end
