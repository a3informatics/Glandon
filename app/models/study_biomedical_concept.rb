class StudyBiomedicalConcept < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#StudyBiomedicalConcept",
            uri_suffix: "STBC",
            uri_unique: true

  object_property :is_derived_from, cardinality: :one, model_class: "BiomedicalConceptInstance"

end
