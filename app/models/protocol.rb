class Protocol < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Protocol",
            uri_suffix: "PR"

  object_property :studyPhase, cardinality: :one, model_class: "OperationalReferenceV3"
  object_property :studyType, cardinality: :one, model_class: "OperationalReferenceV3"


end
