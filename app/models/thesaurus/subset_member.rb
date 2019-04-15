# Thesaurus Preferred term
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::SubsetMember < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#SubsetMember"

  object_property :item, cardinality: :one, model_class: "Thesaurus::Concept"
  object_property :member_next, cardinality: :one, model_class: "Thesaurus::SubsetMember"
  
end