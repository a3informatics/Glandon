class SdtmSponsorDomain < SdtmIgDomain

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomain",
            uri_suffix: "SPD"

  # data_property :prefix
  # data_property :structure

  # object_property :has_biomedical_concept, cardinality: :many, model_class: "OperationalReferenceV3"
  # object_property :based_on_class, cardinality: :one, model_class: "SdtmClass"

  # object_property_class :includes_column, model_class: "SdtmIgDomain::Variable"

end