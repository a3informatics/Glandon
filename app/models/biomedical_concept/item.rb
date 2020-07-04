class BiomedicalConcept::Item < IsoConceptV2

configure rdf_type: "http://www.assero.co.uk/BiomedicalConcept#Item",
          uri_property: :ordinal,
          uri_suffix: 'BCI'
  
  data_property :mandatory, default: true
  data_property :collect, default: true
  data_property :enabled, default: true
  data_property :ordinal, default: 1
  object_property :has_complex_datatype, cardinality: :many, model_class: "BiomedicalConcept::ComplexDatatype", children: true

end