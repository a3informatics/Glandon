class ProtocolEndpoint < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#ProtocolEndpoint",
            base_uri: "http://#{ENV["url_authority"]}/PREND",
            uri_unique: true  

  data_property :full_text
  object_property :derived_from_endpoint, cardinality: :one, model_class: "Endpoint"
  object_property :primary_timepoint, cardinality: :one, model_class: "Timepoint"
  object_property :secondary_timepoint, cardinality: :many, model_class: "Timepoint"
  
end
