class Intervention < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Protocol#Intervention",
            base_uri: "http://#{ENV["url_authority"]}/INV",
            uri_unique: :label,
            cache: true

end