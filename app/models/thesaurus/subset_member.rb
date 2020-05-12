# Thesaurus Subset Member
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::SubsetMember < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#SubsetMember",
            base_uri: "http://#{ENV["url_authority"]}/TSM",
            uri_unique: true

  object_property :item, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept", read_exclude: true
  object_property :member_next, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  include SKOS::Member

end