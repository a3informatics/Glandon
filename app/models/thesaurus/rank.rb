# Thesaurus Rank
#
# @author Dave Iberson-Hurst
# @since 2.40.0
class Thesaurus::Rank < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#RankedCollection",
            base_uri: "http://#{ENV["url_authority"]}/TRC",
            uri_unique: true

  object_property :members, cardinality: :one, model_class: "Thesaurus::RankMember"

  include SKOS::OrderedCollection

private

  def member_klass
    Thesaurus::RankedMember
  end

  def parent_klass
    Thesaurus::ManagedConcept
  end

end