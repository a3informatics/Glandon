module IsoConceptSystemNodeFactory
  
  def create_iso_concept_system_node(params)
    params[:pref_label] = params.key?(:pref_label) ? params[:pref_label] : "PREF LABEL"
    params[:description] = params.key?(:description) ? params[:description] : "A description for testing."
    params[:narrower] = params.key?(:narrower) ? params[:narrower] : []
    IsoConceptSystem::Node.create(params)
  end

end