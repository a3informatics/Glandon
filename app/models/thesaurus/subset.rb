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

  # Set ranks.
  def set_ranks(uris, mc)
    uris.each do |item|
      child = Thesaurus::UnmanagedConcept.find(item)
      set_rank(mc, child)
    end
  end

  # Delete rank member.
  def delete_rank_member(uc, parent_uc)
    uc = Thesaurus::UnmanagedConcept.find(uc)
    rank_uri = parent_uc.is_ranked
    rank = Thesaurus::Rank.find(rank_uri)
    rank.remove_member(rank.member(uc, parent_uc).first)
  end

private

  # Set Rank. 
  #
  # @param mc [String] the id of the cli to be updated
  # @param child [Integer] the rank to be asigned to the cli
  def set_rank(mc, child)
    rank = mc.is_ranked
    query_string = %Q{
      SELECT (max(?rank) as ?maxrank) WHERE {
        #{rank.to_ref} (th:members/th:memberNext*) ?s .
        ?s th:rank ?rank .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th])
    max_rank = query_results.by_object(:maxrank)
    max_rank.empty? ? max_rank = 0 : max_rank = max_rank[0].to_i
    sparql = Sparql::Update.new
    sparql.default_namespace(rank.namespace)
    member = Thesaurus::RankMember.new(item: Uri.new(id: child.uri.to_id), rank: max_rank + 1)
    member.uri = member.create_uri(mc.uri)
    member.to_sparql(sparql)
    last_sm = Thesaurus::Rank.find(rank).last
    last_sm.nil? ? sparql.add({uri: rank}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "members"}, {uri: member.uri}) : sparql.add({uri: last_sm.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "memberNext"}, {uri: member.uri})
    #filename = sparql.to_file
    sparql.create
  end

  def member_klass
    Thesaurus::SubsetMember
  end

  def parent_klass
    Thesaurus::ManagedConcept
  end

end