class StudyAssessment < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#StudyAssessment",
            uri_suffix: "STA",
            uri_unique: true

  object_property :is_derived_from, cardinality: :one, model_class: "Assessment"

end
