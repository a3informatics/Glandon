# ISO Concept V2. Methods for handling of classifiying concepts by linking to terminology.
#
# @author Dave Iberson-Hurst
# @since 3.2.1
class IsoConceptV2

  module ClassifiedAs

    # -------------
    # Class Methods
    # -------------

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
    end

    # Add Tag
    #
    # @param uri_or_id [String|URI] The id or URI of the actual tag being linked to
    # @return [Boolean] returns true if created, false otherwise (exisitng tag)
    def add_tag(uri_or_id)
      uri = self.class.as_uri(uri_or_id)
      return false unless find_classification(self.uri, uri).nil?
      Classification.create(applies_to: self.uri, classified_as: uri, context: [self.uri])
      true
    end

    # Remove Tag
    #
    # @param uri_or_id [String|URI] The id or URI of the Classification object pointing at the tag being unlinked/
    # @return [integer] the number of objects deleted (always 1 if no exception)
    def remove_tag(uri_or_id)
      uri = self.class.as_uri(uri_or_id)
      item = find_classification(self.uri, uri)
      return 0 if item.nil?
      item.delete
    end

    # Tags. Get the tags for the items
    #
    # @return [Array] set of IsoConceptSystem::Node items
    def tags
      result = []
      query_string = %Q{
        SELECT DISTINCT ?s ?p ?o WHERE {
          #{self.uri.to_ref} ^isoC:appliesTo/isoC:classifiedAs ?s .
          ?s ?p ?o
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:isoC])
      query_results.by_subject.each do |subject, triples|
        result << IsoConceptSystem::Node.from_results(Uri.new(uri: subject), triples)
      end
      result
    end

    # Tag labels. Get the ordered tag labels for the items
    #
    # @return [Array] set of ordered String items
    def tag_labels
      tags = self.tags
      tags.map{ |x| x.pref_label }.sort
    end

  end

private

  def find_classification(applies_to, classified_as)
    query_string = %Q{
      SELECT DISTINCT ?s WHERE {
        #{applies_to.to_ref}  ^isoC:appliesTo ?s .
        ?s isoC:classifiedAs #{classified_as.to_ref} .
      }
    }
    uri = Classification.find_single(query_string, [:isoC])
    return nil if uri.nil?
    Classification.find(uri)
  end

end
