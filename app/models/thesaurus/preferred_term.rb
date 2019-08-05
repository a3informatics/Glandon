# Thesaurus Preferred term
#
# @author Dave Iberson-Hurst
# @since 2.22.0
class Thesaurus::PreferredTerm < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#PreferredTerm",
            base_uri: "http://#{ENV["url_authority"]}/PT",
            uri_unique: :label,
            cache: true,
            key_property: :label

end