class Parameter < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Parameter",
            uri_suffix: "PA"

  object_property :parameter_rdf_type, cardinality: :one, model_class: "IsoConceptV2"


end
