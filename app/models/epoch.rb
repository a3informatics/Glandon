class Epoch < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Epoch",
            base_uri: "http://#{ENV["url_authority"]}/EP",
            uri_unique: :label
  
  data_property :ordinal
          
end
