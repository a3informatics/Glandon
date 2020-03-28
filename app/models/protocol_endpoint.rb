class ProtocolEndpoint < Endpoint

  configure rdf_type: "http://www.assero.co.uk/Protocol#ProtocolEndpoint",
            uri_suffix: "PREND"

  object_property :derived_from_endpoint, cardinality: :one, model_class: "Endpoint"
  
end
