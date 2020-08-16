module TypePathManagement

  # Constants
  C_CLASS_NAME = "TypePathManagement"

  @@type_to_class =
  {
    #Thesaurus::C_RDF_TYPE_URI.to_s => { klass: Thesaurus },
    #ThesaurusConcept::C_RDF_TYPE_URI.to_s => { klass: ThesaurusConcept },
    Form.rdf_type.to_s => { klass: Form },
    Form::Group::Normal.rdf_type.to_s => { klass: Form::Group::Normal },
    Form::Group::Common.rdf_type.to_s => { klass: Form::Group::Common },
    Form::Item::BcProperty.rdf_type.to_s => { klass: Form::Item::BcProperty },
    Form::Item::Common.rdf_type.to_s => { klass: Form::Item::Common },
    Form::Item::Mapping.rdf_type.to_s => { klass: Form::Item::Mapping },
    Form::Item::Placeholder.rdf_type.to_s => { klass: Form::Item::Placeholder },
    Form::Item::Question.rdf_type.to_s => { klass: Form::Item::Question },
    Form::Item::TextLabel.rdf_type.to_s => { klass: Form::Item::TextLabel },
    SdtmUserDomain::C_RDF_TYPE_URI.to_s => { klass: SdtmUserDomain },
    SdtmUserDomain::Variable::C_RDF_TYPE_URI.to_s => { klass: SdtmUserDomain::Variable }
  }

  @@mi_history_path =
    { Thesaurus.rdf_type.to_s => { path: Rails.application.routes.url_helpers.history_thesauri_index_path, strong: "thesauri" },
      Thesaurus::ManagedConcept.rdf_type.to_s => { path: Rails.application.routes.url_helpers.history_thesauri_managed_concepts_path, strong: "managed_concept" },
      BiomedicalConceptTemplate.rdf_type.to_s => { path: Rails.application.routes.url_helpers.history_biomedical_concept_templates_path, strong: "biomedical_concept_template" },
      BiomedicalConceptInstance.rdf_type.to_s =>  { path: Rails.application.routes.url_helpers.history_biomedical_concept_instances_path, strong: "biomedical_concept_instance" },
      Form.rdf_type.to_s => { path: Rails.application.routes.url_helpers.history_forms_path, strong: "" },
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
  # @param [Boolean] check_type check the type via a query, defaults to false.
  # @return [String] The url
  def self.history_url_v2(object, check_type=false)
    # Note type query just to make sure we get the real type, not inherited class.
    rdf_type_s = check_type ? object.find_rdf_type.to_s : object.rdf_type.to_s
    Errors.application_error(self.name, __method__.to_s, "Unknown object type #{rdf_type_s} detected.") if !@@mi_history_path.has_key?(rdf_type_s)
    path = @@mi_history_path[rdf_type_s][:path]
    strong = @@mi_history_path[rdf_type_s][:strong]
    return "#{path}/?#{strong}[identifier]=#{object.scoped_identifier}&#{strong}[scope_id]=#{object.owner.ra_namespace.id}"
  end

end
