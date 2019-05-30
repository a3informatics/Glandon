module TypePathManagement

  # Constants
  C_CLASS_NAME = "TypePathManagement"
  
  @@type_to_class = 
  { 
    #Thesaurus::C_RDF_TYPE_URI.to_s => { klass: Thesaurus },
    #ThesaurusConcept::C_RDF_TYPE_URI.to_s => { klass: ThesaurusConcept },
    Form::C_RDF_TYPE_URI.to_s => { klass: Form },
    Form::Group::Normal::C_RDF_TYPE_URI.to_s => { klass: Form::Group::Normal },
    Form::Group::Common::C_RDF_TYPE_URI.to_s => { klass: Form::Group::Common },
    Form::Item::BcProperty::C_RDF_TYPE_URI.to_s => { klass: Form::Item::BcProperty },
    Form::Item::Common::C_RDF_TYPE_URI.to_s => { klass: Form::Item::Common },
    Form::Item::Mapping::C_RDF_TYPE_URI.to_s => { klass: Form::Item::Mapping },
    Form::Item::Placeholder::C_RDF_TYPE_URI.to_s => { klass: Form::Item::Placeholder },
    Form::Item::Question::C_RDF_TYPE_URI.to_s => { klass: Form::Item::Question },
    Form::Item::TextLabel::C_RDF_TYPE_URI.to_s => { klass: Form::Item::TextLabel },
    SdtmUserDomain::C_RDF_TYPE_URI.to_s => { klass: SdtmUserDomain },
    SdtmUserDomain::Variable::C_RDF_TYPE_URI.to_s => { klass: SdtmUserDomain::Variable }
  }

  @@mi_history_path = 
    { Thesaurus.rdf_type.to_s => { path: Rails.application.routes.url_helpers.history_thesauri_index_path, strong: "thesauri" },
      BiomedicalConceptTemplate::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_biomedical_concept_templates_path, strong: "biomedical_concept_template" },
      BiomedicalConcept::C_RDF_TYPE_URI.to_s =>  { path: Rails.application.routes.url_helpers.history_biomedical_concepts_path, strong: "biomedical_concept" },
      Form::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_forms_path, strong: "" },
      SdtmModel::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_sdtm_models_path, strong: "sdtm_model" },
      SdtmIg::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_sdtm_igs_path, strong: "sdtm_ig" },
      AdamIg::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_adam_igs_path, strong: "adam_ig" },
      SdtmUserDomain::C_RDF_TYPE_URI.to_s => { path: Rails.application.routes.url_helpers.history_sdtm_user_domains_path, strong: "sdtm_user_domain" }
    }

  # Method returns class for a given rdf type
  #
  # @param rdf_type [String] the RDF type
  # @return [String] the class
  def self.type_to_class(rdf_type)
    return @@type_to_class[rdf_type][:klass] if @@type_to_class.has_key?(rdf_type)
    raise Exceptions::ApplicationLogicError.new(message: "Class for #{rdf_type} not found in #{C_CLASS_NAME} object.")
  end

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

  # Method returns the strong parameter prefix for a gven rdf type
  #
  # @param [Object] object the managed object
  # @return [String] The url
  def self.history_url_v2(object)
    rdf_type_s = object.rdf_type.to_s
    Errors.application_error(self.name, __method__.to_s, "Unknown object type #{rdf_type_s} detected.") if !@@mi_history_path.has_key?(rdf_type_s) 
    path = @@mi_history_path[rdf_type_s][:path]
    strong = @@mi_history_path[rdf_type_s][:strong]
    return "#{path}/?#{strong}[identifier]=#{object.identifier}&#{strong}[scope_id]=#{object.owner.ra_namespace.id}"
  end

end
