class IsoConceptController < ApplicationController
  
  before_action :authenticate_user!
  
  C_CLASS_NAME = "IsoConceptController"
  C_REFS = 
    [
      OperationalReferenceV2::C_BC_RDF_TYPE_URI.to_s,
      OperationalReferenceV2::C_P_RDF_TYPE_URI.to_s,
      OperationalReferenceV2::C_V_RDF_TYPE_URI.to_s,
      OperationalReferenceV2::C_TC_RDF_TYPE_URI.to_s,
      OperationalReferenceV2::C_T_RDF_TYPE_URI.to_s, 
      OperationalReferenceV2::C_C_RDF_TYPE_URI.to_s
    ]

  def show 
    authorize IsoConcept
    @concept = IsoConcept.find(params[:id], params[:namespace], false)
    respond_to do |format|
      format.html
      format.json do
        render :json => @concept.to_json, :status => 200
      end
    end
  end
  
  def graph
    authorize IsoConcept, :show?
    other_concept = Array.new
    debug = false
    concept = IsoConcept.graph_to(params[:id], params[:namespace])
    if C_REFS.include?(concept[:parent].rdf_type)
      child = concept[:children][0]
      concept = IsoConcept.graph_to(child[:id], child[:namespace])
      other_concept1 = IsoConcept.graph_from(child[:id], child[:namespace])
      other_concept2 = IsoConcept.graph_from(params[:id], params[:namespace])
      other_concept = other_concept1 + other_concept2
      #debug = true
    else
      other_concept = IsoConcept.graph_from(params[:id], params[:namespace])
    end
    @result = concept[:parent].to_json
    @result[:children] = Array.new
    @result[:parent] = Array.new
    concept[:children].each do |child|
      @result[:children] << child
    end
    other_concept.each do |parent|
      @result[:parent] << parent
    end
    #ConsoleLogger::log(C_CLASS_NAME,"graph","Results=#{@result.to_json}") if debug
    respond_to do |format|
      format.html
      format.json do
        render :json => @result, :status => 200
      end
    end
  end

private

  def this_params
    params.require(:iso_concept).permit(:namespace)
  end

end
