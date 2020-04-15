class StudyForm < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#StudyForm",
            uri_suffix: "STFRM",
            uri_unique: true

  object_property :is_derived_from, cardinality: :one, model_class: "Form"

end
