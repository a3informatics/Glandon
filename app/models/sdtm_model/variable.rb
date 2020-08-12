class SdtmModel::Variable < Tabulation::Column

  configure rdf_type: "http://www.assero.co.uk/Tabulation#SdtmModelVariable",
            uri_suffix: "MV",
            uri_property: :name

  data_property :name
  data_property :prefixed
  data_property :description
  
end
