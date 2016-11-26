class IsoConceptController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoConceptController"
  
  def show 
    authorize IsoConcept
    @concept = IsoConcept.find(params[:id], params[:namespace], false)
    render :json => @concept.to_json, :status => 200
  end
  
  def graph
    authorize IsoConcept, :show?
    concept = IsoConcept.find(params[:id], params[:namespace])
    @result = { uri: concept.uri.to_s, rdf_type: concept.rdf_type }
  end

  def graph_links
    authorize IsoConcept, :show?
    results = IsoConcept.links_from(params[:id], params[:namespace])
    results += IsoConcept.links_to(params[:id], params[:namespace])
    results.each do |result|
      result[:uri] = result[:uri].to_s
    end
    render :json => results, :status => 200
  end

  def impact
    authorize IsoConcept, :show?
    managed_items = []
    map = {}
    @item = IsoConcept.find(params[:id], params[:namespace], false)
    concepts = IsoConcept.links_to(params[:id], params[:namespace])
    concepts.each do |concept|
      managed_item = IsoManaged.find_managed(concept[:uri].id, concept[:uri].namespace)
      uri_s = managed_item[:uri].to_s
      managed_items << { uri: uri_s, rdf_type: managed_item[:rdf_type]} if !map.has_key?(uri_s)
      map[uri_s] = true
    end
    @results = {item: @item.to_json, children: managed_items}
  end

private

  def this_params
    params.require(:iso_concept).permit(:namespace)
  end

end
