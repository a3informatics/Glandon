class TherapeuticArea < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#TherapeuticArea",
            uri_suffix: "TA"

  object_property :includes_indication, cardinality: :many, model_class: "Indication"

end