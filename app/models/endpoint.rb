class Endpoint < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Endpoint",
            uri_suffix: "END"

  data_property :full_text
  object_property :has_multiple, cardinality: :many, model_class: "Endpoint"
  object_property :has_parameter, cardinality: :many, model_class: "Parameter"


end
