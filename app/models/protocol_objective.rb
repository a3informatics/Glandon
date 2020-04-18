class ProtocolObjective < Objective

  configure rdf_type: "http://www.assero.co.uk/Protocol#ProtocolObjective",
            uri_suffix: "PROB",
            uri_unique: true
  
  object_property :derived_from, cardinality: :one, model_class: "Objective"
 
end
