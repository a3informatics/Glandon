class IsoContextualRelationship < Fuseki::Base

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#ContextualRelationship",
            base_uri: "http://#{ENV["url_authority"]}/CREL",
            uri_unique: true
  
  object_property :applies_to, cardinality: :one, model_class: "IsoConceptV2"
  object_property :context, cardinality: :many, model_class: "IsoConceptV2"

end