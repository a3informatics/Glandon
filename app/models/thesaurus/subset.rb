# Thesaurus Subset
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::Subset < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Subset",
            base_uri: "http://#{ENV["url_authority"]}/TS",
            uri_unique: true

  object_property :members, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  include SKOS::OrderedCollection

  # 
  def find_mc
    parent
  end

private

  def member_klass
    Thesaurus::SubsetMember
  end

  def parent_klass
    Thesaurus::ManagedConcept
  end

end