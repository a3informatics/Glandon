class StudyForm < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#StudyForm",
            base_uri: "http://#{ENV["url_authority"]}/STFRM",
            uri_unique: true

  object_property :is_derived_from, cardinality: :one, model_class: "Form"

end
