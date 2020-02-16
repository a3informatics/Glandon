# Managed Concepts Extensions
#
# @author Dave Iberson-Hurst
# @since 2.34.0
class Thesaurus

  module Subsets

    # Upgrade. Upgrade the Managed Concept to refer to the new reference. Adjust references accordingly
    # This will be all the children in the current subset that exist in the new reference in the same order.
    #
    # @param new_reference [Thesurus::ManagedConcept] the new reference
    # @return [Void] no return
    def upgrade_subset(new_reference)
      subset = self.is_ordered_objects
      self.subsets = new_reference
      uris = subset_children(new_reference)
      self.narrower = uris
      self.save
      subset.delete_subset
      subset.add(uris.map{|x| x.to_id})
      self
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

    # Get the subset children. The order is t be preserved.
    def subset_children(new_reference)
      set = self.is_ordered_objects.list_uris
      query_string = "SELECT DISTINCT ?e WHERE { VALUES ?s { #{set.map{|x| x[:uri].to_ref}.join(" ")} } ?s th:identifier ?i . #{new_reference.uri.to_ref} th:narrower ?e . ?e th:identifier ?i . }"
      query_results = Sparql::Query.new.query(query_string, uri.namespace, [:th])
      query_results.by_object_set([:e]).map{|x| x[:e]}
    end

  end

end