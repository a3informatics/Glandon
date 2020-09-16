class Tabulation::Column < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Tabulation#Column",
            uri_suffix: "C"

  data_property :rule
  data_property :ordinal, default: 1
  
  validates_with Validator::Field, attribute: :ordinal, method: :valid_positive_integer?

end
