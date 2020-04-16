class ProtocolObjective < Objective

  configure rdf_type: "http://www.assero.co.uk/Protocol#ProtocolObjective",
            uri_suffix: "PROB"
  
  object_property :derived_from_objective, cardinality: :one, model_class: "Objective"
 
end
