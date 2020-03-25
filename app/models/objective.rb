class Objective < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Objective",
            uri_suffix: "OB"

  data_property :full_text
  object_property :is_assessed_by, cardinality: :one, model_class: "Endpoint"
  #  object_property :objective_type, cardinality: :one, model_class: "Enumerated"
  object_property :has_parameter, cardinality: :many, model_class: "Parameter"

end
