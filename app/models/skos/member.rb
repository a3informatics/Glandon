# Thesaurus Subset Member
#
# @author Dave Iberson-Hurst
# @since 2.21.2
module SKOS::Member 

  # Assumes :members declared
  # object_property :item, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept", read_exclude: true
  # object_property :member_next, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  # Previous. Find previous item
  #
  # @return [Object] the next member
  def previous
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (^th:memberNext) ?s .
        ?s ?p ?o
      }
    }
    triples = Sparql::Query.new.query(query_string, "", [:th]).single_subject
    triples.nil? ? nil : self.class.from_results(Uri.new(uri: triples.keys.first), triples)
  end

  # Next. Find next item
  #
  # @return [Object] the next member
  def next
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (th:memberNext) ?s .
          ?s ?p ?o
         }
      }
    triples = Sparql::Query.new.query(query_string, "", [:th]).single_subject
    triples.nil? ? nil : self.class.from_results(Uri.new(uri: triples.keys.first), triples)
  end

end