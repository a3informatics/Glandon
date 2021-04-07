class Indication < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Indication",
            uri_suffix: "IND"

  object_property :indication, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept", delete_exclude: true, read_exclude: true
  object_property :has_objective, cardinality: :many, model_class: "Objective"

end
