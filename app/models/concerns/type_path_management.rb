module TypePathManagement

  # Constants
  C_CLASS_NAME = "TypePathManagement"
  
  @@mi_history_path = 
    { Thesaurus::C_RDF_TYPE_URI.to_s => Rails.application.routes.url_helpers.history_thesauri_index_path,
      BiomedicalConceptTemplate::C_RDF_TYPE_URI.to_s => Rails.application.routes.url_helpers.history_biomedical_concept_templates_path,
      BiomedicalConcept::C_RDF_TYPE_URI.to_s =>  Rails.application.routes.url_helpers.history_biomedical_concepts_path,
      Form::C_RDF_TYPE_URI.to_s => Rails.application.routes.url_helpers.history_forms_path,
      SdtmModel::C_RDF_TYPE_URI.to_s => Rails.application.routes.url_helpers.history_sdtm_models_path,
      SdtmIg::C_RDF_TYPE_URI.to_s => Rails.application.routes.url_helpers.history_sdtm_igs_path,
      SdtmIgDomain::C_RDF_TYPE_URI.to_s => Rails.application.routes.url_helpers.history_sdtm_ig_domains_path,
      SdtmUserDomain::C_RDF_TYPE_URI.to_s => Rails.application.routes.url_helpers.history_sdtm_user_domains_path
    }

  def self.history_path(rdf_type)
    if @@mi_history_path.has_key?(rdf_type) 
      return @@mi_history_path[rdf_type]
    else
      return ""
    end
  end

end
