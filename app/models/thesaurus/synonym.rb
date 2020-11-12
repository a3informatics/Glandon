# Thesaurus Synonym
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus::Synonym < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Synonym",
            base_uri: "http://#{ENV["url_authority"]}/SYN",
            uri_unique: :label,
            cache: true,
            key_property: :label

end