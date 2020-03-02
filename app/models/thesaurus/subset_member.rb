# Thesaurus Subset Member
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::SubsetMember < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#SubsetMember",
            base_uri: "http://#{ENV["url_authority"]}/TSM",
            uri_unique: true

  object_property :item, cardinality: :one, model_class: "Thesaurus::UnmanagedConcept", read_exclude: true
  object_property :member_next, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  #Previous. Find previous item
  def previous_member
      objects = []
      query_string = %Q{
        SELECT DISTINCT ?s ?p ?o WHERE {
          #{self.uri.to_ref} (^th:memberNext) ?s .
          ?s ?p ?o
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      return nil if query_results.empty?
      query_results.by_subject.each do |subject, triples|
        objects << Thesaurus::SubsetMember.from_results(Uri.new(uri: subject), triples)
      end
      return objects.first if objects.count == 1
      Errors.application_error(self.class.name, __method__.to_s, "Multiple previous members found.")
  end

  #Next. Find next item
  def next_member
    objects = []
      query_string = %Q{
        SELECT DISTINCT ?s ?p ?o WHERE {
          #{self.uri.to_ref} (th:memberNext) ?s .
            ?s ?p ?o
           }
        }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      return nil if query_results.empty?
      query_results.by_subject.each do |subject, triples|
        objects << Thesaurus::SubsetMember.from_results(Uri.new(uri: subject), triples)
      end
      return objects.first if objects.count == 1
      Errors.application_error(self.class.name, __method__.to_s, "Multiple next members found.")
  end

end