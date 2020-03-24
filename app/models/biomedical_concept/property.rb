class BiomedicalConcept::Property < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#Property",
            uri_property: :label,
            uri_suffix: 'BCP'

  data_property :question_text
  data_property :prompt_text
  data_property :format
  object_property :has_coded_value, cardinality: :many, model_class: "Thesaurus::UnmanagedConcept"
  object_property :is_a, cardinality: :one, model_class: "CanonicalReference"

  validates_with Validator::Field, attribute: :question_text, method: :valid_question?
  validates_with Validator::Field, attribute: :prompt_text, method: :valid_question?
  validates_with Validator::Field, attribute: :format, method: :valid_format?

  # def remove
  #   update = UriManagement.buildNs(self.namespace, ["cbc"]) +
  #     "DELETE \n" +
  #     "{\n" +
  #     "  :" + self.id + " cbc:hasThesaurusConcept ?s .\n" +
  #     "  ?s ?p ?o .\n"+
  #     "}\n" +
  #     "WHERE \n" +
  #     "{\n" +
  #     "  :" + self.id + " cbc:hasThesaurusConcept ?s .\n" +
  #     "  ?s ?p ?o .\n"+
  #     "}\n"
  #   response = CRUD.update(update)
  #   if !response.success?
  #     ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
  #     raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
  #   end
  # end

  # def add(params)
  #   sparql = SparqlUpdateV2.new
  #   subject = {:uri => self.uri}
  #   params[:tc_refs].each do |ref|
  #     tc_ref = OperationalReferenceV2.new()
  #     tc_ref.subject_ref = UriV2.new({id: ref[:subject_ref][:id], namespace: ref[:subject_ref][:namespace]})
  #     tc_ref.ordinal = ref[:ordinal]
  #     ref_uri = tc_ref.to_sparql_v2(uri, "hasThesaurusConcept", 'TCR', tc_ref.ordinal, sparql)
  #     sparql.triple(subject, {:prefix => C_SCHEMA_PREFIX, :id => "hasThesaurusConcept"}, {:uri => ref_uri})
  #   end
  #   response = CRUD.update(sparql.to_s)
  #   if !response.success?
  #     ConsoleLogger.info(C_CLASS_NAME, "add", "Failed to update object.")
  #     raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
  #   end
  # end

end