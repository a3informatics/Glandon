class SdtmClass::Variable < Tabulation::Column

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmClassVariable",
            uri_suffix: "CV",
            uri_property: :ordinal

  object_property :based_on_model_variable, cardinality: :one, model_class: "SdtmModel::Variable"

end
