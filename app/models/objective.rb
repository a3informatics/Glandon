class Objective < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Objective",
            uri_suffix: "OB"

  data_property :fullText
  object_property :isAssessedBy, cardinality: :one, model_class: "Endpoint"
  object_property :type, cardinality: :many, model_class: ""

end
