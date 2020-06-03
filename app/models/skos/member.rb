# SKOS Member. A member of an ordered collection
#
# @author Dave Iberson-Hurst
# @since 2.24.0
module SKOS::Member 

  # Assumes :members declared
  # object_property :item, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept"
  # object_property :member_next, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  # Previous. Find previous item
  #
  # @return [Object] the next member or nil
  def previous_member
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (^th:memberNext) ?s .
        ?s ?p ?o
      }
    }
    Sparql::Query.new.query(query_string, "", [:th]).single_subject_as(self.class)
  end

  # Next. Find next item
  #
  # @return [Object] the next member or nil.
  def next_member
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (th:memberNext) ?s .
          ?s ?p ?o
         }
      }
    Sparql::Query.new.query(query_string, "", [:th]).single_subject_as(self.class)
  end

end