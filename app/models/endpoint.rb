class Endpoint < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Endpoint",
            uri_suffix: "EN"

  data_property :full_text
  object_property :hasMultiple, cardinality: :many, model_class: "Endpoint"

end
