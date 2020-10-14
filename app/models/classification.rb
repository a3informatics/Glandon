class Classification < IsoContextualRelationship

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Classification",
            base_uri: "http://#{ENV["url_authority"]}/CLA",
            uri_unique: true
  
  object_property :classified_as, cardinality: :one, model_class: "IsoConcept"

end