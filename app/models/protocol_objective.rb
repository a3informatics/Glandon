class ProtocolObjective < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#ProtocolObjective",
            base_uri: "http://#{ENV["url_authority"]}/PROBJ",
            uri_unique: true  
  
  data_property :full_text
  object_property :derived_from_objective, cardinality: :one, model_class: "Objective"
  object_property :is_assessed_by, cardinality: :many, model_class: "ProtocolEndpoint"
  object_property :objective_type, cardinality: :one, model_class: "Enumerated"
 
end
