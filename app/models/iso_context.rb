class IsoContext < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Context",
            base_uri: "http://#{ENV["url_authority"]}/CNXT",
            uri_unique: true
  
  object_property :applied_to, cardinality: :one, model_class: "IsoConceptV2"
  object_property :context, cardinality: :many, model_class: "IsoConceptV2"

end