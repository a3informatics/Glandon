# Thesaurus Validation. Validation methods
#
# @author Dave Iberson-Hurst
# @since 2.39.0
class Thesaurus

  module Validation

    # Valid Child? Check that the child is valid in the context of the parent item.
    #
    # @param child [Thesaurus::UnmanagedConcept] the child the item
    # @return [Boolean] true if valid, false otherwise
    def valid_child?(child)
      # Want both chcks run
      valid1 = !duplicate_notation?(child)
      valid2 = !duplicate_preferred_terms?(child)    
      valid1 && valid2
    end

    # Valid Children? Check that the children are valid in the context of the parent item.
    #
    # @return [Boolean] true if valid, false otherwise
    def valid_children?
      nt = self.narrower.map{|x| x.notation}.find_all_duplicates
      pt = self.narrower.map{|x| x.preferred_term.label}.find_all_duplicates
      return true if nt.empty? && pt.empty?
      self.errors.add(:notation, "duplicates detected #{nt.map{|x| "'#{x}'"}.join(", ")}") if nt.any?
      self.errors.add(:preferred_term, "duplicates detected #{pt.map{|x| "'#{x}'"}.join(", ")}") if pt.any?
      false
    end

private

    #
    # Duplicate Notation?
    def duplicate_notation?(child)
      return false unless notations(child).include?(child.notation)
      child.errors.add(:notation, "duplicate detected '#{child.notation}'")
      true
    end

    # Duplicate Preferred Term?
    def duplicate_preferred_terms?(child)
      return false unless preferred_terms(child).include?(child.preferred_term.label)
      child.errors.add(:preferred_term, "duplicate detected '#{child.preferred_term.label}'")
      true
    end

    # Notations
    def notations(child)
      minus_clause = child.uri.blank? ? "" : "FILTER (?s != #{(child.uri.to_ref)})"
      query_string = %Q{
        SELECT ?n WHERE {
          #{self.uri.to_ref} th:narrower ?s .
          #{minus_clause}
          ?s th:notation ?n
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      query_results.by_object(:n)
    end

    # Preferred Terms
    def preferred_terms(child)
      minus_clause = child.uri.blank? ? "" : "FILTER (?s != #{(child.uri.to_ref)})"
      query_string = %Q{
        SELECT ?l WHERE {
          #{self.uri.to_ref} th:narrower ?s .
          #{minus_clause}
          ?s th:preferredTerm/isoC:label ?l
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th, :isoC])
      query_results.by_object(:l)
    end

  end

end
