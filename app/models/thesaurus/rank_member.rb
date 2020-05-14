# Thesaurus Rank Member
#
# @author Dave Iberson-Hurst
# @since 2.40.0
class Thesaurus::RankMember < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#RankedMember",
            base_uri: "http://#{ENV["url_authority"]}/TRM",
            uri_unique: true

  data_property :rank
  object_property :item, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept", read_exclude: true
  object_property :member_next, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  include SKOS::Member

end