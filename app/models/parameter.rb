class Parameter < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Parameter",
            base_uri: "http://#{ENV["url_authority"]}/PARAM",
            uri_unique: :label,
            cache: true

  object_property :parameter_rdf_type, cardinality: :one, model_class: "IsoConceptV2"

end