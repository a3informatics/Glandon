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

  # Add. Add a new subset member to the Subset
  #
  # @param uc_id [String] the identifier of the unmanaged concept to be linked to the new subset member
  # @return [Object] the created Subset Member
  def add(uc_id)
    transaction_begin
    sm = Thesaurus::SubsetMember.create({item: Uri.new(id: uc_id), uri: Thesaurus::SubsetMember.create_uri(self.uri)})
    last_sm = self.last
    last_sm.nil? ? self.add_link(:members, sm.uri) : last_sm.add_link(:member_next, sm.uri)
    transaction_execute
    sm
  end

  # Remove. Remove a subset member of the Subset
  #
  # @param subset_member_id [String] the identifier of the subset member to be removed
  def remove(subset_member_id)
    transaction_begin
    sm = Thesaurus::SubsetMember.find(subset_member_id)
    prev_sm = sm.previous_member
    if prev_sm.nil?
      self.delete_link(:members, sm.uri)
      self.add_link(:members, sm.next_member.uri)
    else 
      prev_sm.delete_link(:member_next, sm.uri)
      prev_sm.add_link(:member_next, sm.next_member.uri)
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

  # Move After. Move an subset member after another subset member given
  #
  # @param this_member_id [String] the identifier of the subset member to be moved after
  # @param to_after_member_id [String] the identifier of the subset member to which the subset member moves after
  def move_after(this_member_id, to_after_member_id = nil)
    transaction_begin
    sm = Thesaurus::SubsetMember.find(this_member_id)
    prev_sm = sm.previous_member
    if to_after_member_id.nil? #Moving to the first position
      prev_sm.delete_link(:member_next, sm.uri)
      prev_sm.add_link(:member_next, sm.next_member.uri)
      old_first = self.members
      self.delete_link(:members, prev_sm.uri)
      self.add_link(:members, sm.uri)
      sm.delete_link(:member_next, sm.next_member.uri)
      sm.add_link(:member_next, old_first)
    else
      last = self.last
      to_after_sm = Thesaurus::SubsetMember.find(to_after_member_id)
      if last.uri == sm.uri #Moving the last element
        prev_sm.delete_link(:member_next, sm.uri)
        sm.add_link(:member_next, to_after_sm.next_member.uri)
        to_after_sm.delete_link(:member_next, to_after_sm.next_member.uri)
        to_after_sm.add_link(:member_next, sm.uri)
      else
        prev_sm.delete_link(:member_next, sm.uri)
        prev_sm.add_link(:member_next, sm.next_member.uri)
        sm.delete_link(:member_next, sm.next_member.uri)
        sm.add_link(:member_next, to_after_sm.next_member.uri)
        to_after_sm.delete_link(:member_next, to_after_sm.next_member.uri)
        to_after_sm.add_link(:member_next, sm.uri)
      end
    end
    transaction_execute
  end

end