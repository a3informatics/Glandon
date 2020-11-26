class SdtmSponsorDomain::Variable < SdtmIgDomain::Variable

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmSponsorDomainVariable",
            uri_property: :name

  data_property :comment
  data_property :used
  data_property :notes
  object_property :typed_as, cardinality: :one, model_class: "IsoConceptSystem::Node", delete_exclude: true
  object_property :based_on_ig_variable, cardinality: :one, model_class: "SdtmIgDomain::Variable"

end