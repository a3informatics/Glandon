class Arm < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Arm",
            base_uri: "http://#{ENV["url_authority"]}/ARM",
            uri_unique: true

  data_property :description
  data_property :arm_type
  data_property :ordinal

end
