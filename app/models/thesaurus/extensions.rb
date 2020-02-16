# Managed Concepts Extensions
#
# @author Clarisa Romero
# @since 2.33.0
class Thesaurus

  module Extensions

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods

      # Can extend unextensible?
      #
      # @return [Boolean] true if can extend an unextensible managed concept
      def can_extend_unextensible?
        extensions_configuration[:can_extend_unextensible]
      end

    private
      
      def extensions_configuration
        Rails.configuration.thesauri[:extensions]
      end

    end

    # Extended? Is this item extended
    #
    # @result [Boolean] return true if extended
    def extended?
      !extended_by.nil?
    end

    # Extended By. Get the URI of the extension item if it exists.
    #
    # @result [Uri] the Uri or nil if not present.
    def extended_by
      query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} ^th:extends ?s }}
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      return query_results.empty? ? nil : query_results.by_object_set([:s]).last[:s]
    end

    # Extension? Is this item extending another managed concept
    #
    # @result [Boolean] return true if extending another
    def extension?
      !extension_of.nil?
    end

    # Extension Of. Get the URI of the item being extended, if it exists.
    #
    # @result [Uri] the Uri or nil if not present.
    def extension_of
      query_string = %Q{SELECT ?s WHERE { #{self.uri.to_ref} th:extends ?s }}
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      return query_results.empty? ? nil : query_results.by_object_set([:s]).first[:s]
    end

    # Upgrade. Upgrade the Managed Concept to refer to the new reference. Adjust references accordingly
    # This will be all the children of the new reference plus the extending items already present
    #
    # @param new_reference [Thesurus::ManagedConcept] the new reference
    # @return [Void] no return
    def upgrade_extension(new_reference)
      self.extends = new_reference
byebug
      self.narrower = extension_children(new_reference)
      self.save
      self
    end

  private

    # Get the extension children
    def extension_children(new_reference)
      parts = []
      parts << "{ #{new_reference.uri.to_ref} th:narrower ?s }"
      parts << "{ #{self.uri.to_ref} th:narrower ?s . FILTER NOT EXISTS { ?s ^th:narrower #{new_reference.uri.to_ref} . }}"
      query_string = "SELECT DISTINCT ?s WHERE { #{parts.join(" UNION\n")} }"
  puts "*****\n#{query_string}\n*****"
      query_results = Sparql::Query.new.query(query_string, uri.namespace, [:th])
      query_results.by_object_set([:s]).map{|x| x[:s]}
    end

  end

end