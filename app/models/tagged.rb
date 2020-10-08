class Tagged < IsoContext

  configure rdf_type: "http://www.assero.co.uk/ISO11179Concepts#Tag",
            base_uri: "http://#{ENV["url_authority"]}/TAG",
            uri_unique: true
  
  object_property :with, cardinality: :one, model_class: "IsoConcept"

end