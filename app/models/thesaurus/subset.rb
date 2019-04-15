# Thesaurus Preferred term
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::Subset < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Subset"

  object_property :members, cardinality: :one, model_class: "Thesaurus::SubsetMember"
  
end