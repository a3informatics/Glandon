# Thesaurus Subset
#
# @author Dave Iberson-Hurst
# @since 2.21.2
class Thesaurus::Subset < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/Thesaurus#Subset",
            base_uri: "http://#{ENV["url_authority"]}/TS",
            uri_unique: true

  object_property :members, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  # Last. Find last item in the list
  def last
    objects = []
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (th:members/th:memberNext*) ?s .
        FILTER NOT EXISTS { ?s th:memberNext ?c }
        ?s ?p ?o
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th])
    return nil if query_results.empty?
    query_results.by_subject.each do |subject, triples|
      objects << Thesaurus::SubsetMember.from_results(Uri.new(uri: subject), triples)
    end
    return objects.first if objects.count == 1
    Errors.application_error(self.class.name, __method__.to_s, "Multiple last subset members found.")
  end

  def add(concept_id)
    transaction_begin
    sm = Thesaurus::SubsetMember.create({item: Uri.new(id: concept_id), uri: Thesaurus::SubsetMember.create_uri(self.uri)})
    last_sm = self.last
    last_sm.nil? ? self.add_link(:members, sm.uri) : last_sm.add_link(:member_next, sm.uri)
    transaction_execute
    sm
  end

  def remove(subset_member_id)
    transaction_begin
    sm = Thesaurus::SubsetMember.find(subset_member_id)
    prev_sm = sm.previous_member
    next_sm = sm.next_member
    if prev_sm.nil?
      self.delete_link(:members, sm.uri)
      self.add_link(:members, next_sm.uri)
    else 
      prev_sm.delete_link(:member_next, sm.uri)
      prev_sm.add_link(:member_next, next_sm.uri)
    end
    sm.delete
    transaction_execute
  end

  #----------
  # Test Only
  #----------
  if Rails.env.test?
  
    def list
      objects = []
      query_string = %Q{
        SELECT DISTINCT ?s ?p ?o WHERE {
          #{self.uri.to_ref} (th:members/th:memberNext*) ?s .
          ?s ?p ?o
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      query_results.by_subject.each do |subject, triples|
        objects << Thesaurus::SubsetMember.from_results(Uri.new(uri: subject), triples)
      end
      objects
    end
  
  end

  def move_after(this_member_id, to_after_member_id = nil)
    self.append_first(concept_id) if concept_id_after.nil?
    sm = Thesaurus::SubsetMember.delete({item: Uri.new(id: concept_id), uri: })
    append_after(id_cli, id_cli_after)
  end

end