# ISO Concept V2. Methods for handling of managed ancestors (parent managed items) operations.
#
# @author Dave Iberson-Hurst
# @since 3.2.0
class IsoConceptV2

  module ManagedAncestors

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    # # Add Tags No Save. Add tags if not already present, dont save
    # #
    # # @param tags [Array] array of IsoConceptSystem::Node items
    # # @return [Void] no return
    # def add_tags_no_save(tags)
    #   uris = self.tagged.map{|x| x.uri}
    #   tags.each do |tag|
    #     self.tagged << tag if !uris.include?(tag.uri)
    #   end
    # end

    # # Add Tag No Save. Add a tag if not already present, dont dave
    # #
    # # @param tag [IsoConceptSystem] a single IsoConceptSystem::Node item
    # # @return [Void] no return
    # def add_tag_no_save(tag)
    #   self.tagged << tag if !self.tagged.map{|x| x.uri}.include?(tag.uri)
    # end

    # Add Tag
    #
    # @param uri_or_id [String|URI] The id or URI of the actual tag being linked to
    # @return [Boolean] returns true if created, false otherwise (exisitng tag)
    def add_tag(uri_or_id)
      uri = self.class.as_uri(uri_or_id)
      return false unless Tagged.where(applied_to: self.uri, with: uri).empty?
      Tagged.create(applied_to: self.uri, with: uri, context: nil)
      true
    end

    # Remove Tag
    #
    # @param uri_or_id [String|URI] The id or URI of the Tagged object pointing at the tag being unlinked/
    # @return [integer] the number of objects deleted (always 1 if no exception)
    def remove_tag(uri_or_id)
      uri = self.class.as_uri(uri_or_id)
      Tagged.find(uri)
      Tagged.delete
    end

    # # Tags. Get the tags for the items
    # #
    # # @return [Array] set of IsoConceptSystem::Node items
    # def tags
    #   result = []
    #   query_string = %Q{
    #     SELECT DISTINCT ?s ?p ?o WHERE {
    #       #{self.uri.to_ref} isoC:tagged ?s .
    #       ?s ?p ?o
    #     }
    #   }
    #   query_results = Sparql::Query.new.query(query_string, "", [:isoC])
    #   query_results.by_subject.each do |subject, triples|
    #     result << IsoConceptSystem::Node.from_results(Uri.new(uri: subject), triples)
    #   end
    #   result
    # end

    # # Tag labels. Get the ordered tag labels for the items
    # #
    # # @return [Array] set of ordered String items
    # def tag_labels
    #   tags = self.tags
    #   tags.map{ |x| x.pref_label }.sort
    # end

  end


end
