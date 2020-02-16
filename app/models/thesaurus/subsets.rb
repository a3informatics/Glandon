# Managed Concepts Extensions
#
# @author Dave Iberson-Hurst
# @since 2.34.0
class Thesaurus

  module Subsets

    def upgrade_subset(new_reference)
    end
    
    # Subset? Is this item subsetting another managed concept
    #
    # @result [Boolean] return true if this instance is a subset of another
    def subset?
      !self.subset_of.nil?
    end

    # Subset Of. What is this subsetting
    #
    # @result [Uri] the URI of the item being subsetted
    def subset_of
      query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} th:subsets ?s }}
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      return query_results.empty? ? nil : query_results.by_object_set([:s]).first[:s]
    end

    # Finds the subsets of this Thesaurus::ManagedConcept
    #
    # @return [Array] Uri of subsets referring to this instance, nil if none found
    def subsetted_by
      query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} ^th:subsets ?s }}
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      return query_results.empty? ? nil : query_results.by_object_set([:s])
    end

  private
      
  end

end