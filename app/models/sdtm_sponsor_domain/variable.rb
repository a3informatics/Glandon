class SdtmSponsorDomain::Variable < SdtmIgDomain::Variable

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomainVariable",
            uri_property: :name

  # data_property :name
  # data_property :description
  # data_property :format
  # data_property :ct_and_format
  # object_property :compliance, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  # object_property :ct_reference, cardinality: :many, model_class: "OperationalReferenceV3::TmcReference"
  # object_property :based_on_class_variable, cardinality: :one, model_class: "SdtmClass::Variable"
  # object_property :is_a, cardinality: :one, model_class: "CanonicalReference", delete_exclude: true

end