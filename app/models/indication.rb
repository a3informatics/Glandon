class Indication < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Indication",
            uri_suffix: "IN"

  object_property :indicationName, cardinality: :one, model_class: "OperationalReferenceV3"
  object_property :has, cardinality: :one, model_class: "Objective"

end
