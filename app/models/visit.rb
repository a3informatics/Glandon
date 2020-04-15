class Visit < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Visit",
            base_uri: "http://#{ENV["url_authority"]}/VI",
            uri_unique: :short_name
  
  data_property :short_name

end
