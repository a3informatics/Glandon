module TypePathManagement

  # Constants
  C_CLASS_NAME = "TypePathManagement"
  
  @@mi_history_path = 
    { Thesaurus::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_thesauri_index_path, strong: "" },
      BiomedicalConceptTemplate::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_biomedical_concept_templates_path, strong: "biomedical_concept_template" },
      BiomedicalConcept::C_RDF_TYPE_URI.to_s =>  { path: Rails.application.routes.url_helpers.history_biomedical_concepts_path, strong: "biomedical_concept" },
      Form::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_forms_path, strong: "" },
      SdtmModel::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_sdtm_models_path, strong: "sdtm_model" },
      SdtmIg::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_sdtm_igs_path, strong: "" },
      SdtmIgDomain::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_sdtm_ig_domains_path, strong: "" },
      SdtmUserDomain::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_sdtm_user_domains_path, strong: "sdtm_user_domain" }
    }

  # Method returns the history path for a given rdf type
  #
  # @param rdf_type [String] the RDF type
  # @return [String] the path
  def self.history_path(rdf_type)
    if @@mi_history_path.has_key?(rdf_type) 
      return @@mi_history_path[rdf_type][:path]
    else
      return ""
    end
  end

  # Method returns the strong parameter prefix for a gven rdf type
  #
  # @param text [String] the RDF type
  # @param ientifier [String] the idetifier
  # @param scope_id [String] the scope id
  # @return [String] The url
  def self.history_url(rdf_type, identifier, scope_id)
    if @@mi_history_path.has_key?(rdf_type) 
      path = @@mi_history_path[rdf_type][:path]
      strong = @@mi_history_path[rdf_type][:strong]
      if strong.empty?
        return "#{path}/?identifier=#{identifier}&scope_id=#{scope_id}"
      else
        return "#{path}/?#{strong}[identifier]=#{identifier}&#{strong}[scope_id]=#{scope_id}"
      end
    else
      return ""
    end
  end

end
