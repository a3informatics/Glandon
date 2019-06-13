class IsoConceptSystems::NodesController < ApplicationController
  
  before_action :authenticate_user!
  
  def add
    authorize IsoConceptSystem::Node, :create?
    node = IsoConceptSystem::Node.find(params[:id], params[:namespace])
    new_node = node.add(the_params)
    if new_node.errors.blank?
      flash[:success] = 'The tag was successfully created.'
    else
      flash[:error] = "Something went wrong and the tag was not created. #{new_node.errors.full_messages.to_sentence}."
    end
    redirect_to iso_concept_systems_node_path(:id => node.id, :namespace => node.namespace)
  end

  def destroy
    authorize IsoConceptSystem::Node
    node = IsoConceptSystem::Node.find(params[:id], params[:namespace])
    if node.children.length == 0
      node.destroy
      flash[:success] = 'The tag was successfully deleted.'
    else
      flash[:error] = "Child tags exist, this tag cannot be deleted."
    end
    redirect_to iso_concept_systems_node_path(:id => params[:parent_id], :namespace => params[:parent_namespace])
  end

  def update
    authorize IsoConceptSystem::Node
    node = IsoConceptSystem::Node.find(params[:id], params[:namespace])
    node.update(the_params)
    render :json => {}, :status => 200
  rescue => e
    render :json => {errors: "Something went wrong updating the tag."}, :status => 500
  end
  
private

    def the_params
      params.require(:iso_concept_systems_node).permit(:label, :description)
    end

end
