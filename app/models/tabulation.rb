# Tabulation
#
# @author Dave Iberson-Hurst
# @since 2.21.0
class Tabulation < IsoManagedV2

  configure rdf_type: "http://www.assero.co.uk/Tabulation#Tabulation",
            uri_suffix: "T"

  data_property :rule
  data_property :ordinal, default: 1

  object_property :includes_column, cardinality: :many, model_class: "Tabulation::Column", 
    model_classes: 
      [ 
        "SdtmClass::Variable", "SdtmModel::Variable"
      ],
    children: true

end