class StudyAssessment < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#StudyAssessment",
            base_uri: "http://#{ENV["url_authority"]}/STA",
            uri_unique: true

  object_property :is_derived_from, cardinality: :one, model_class: "Assessment"

end
