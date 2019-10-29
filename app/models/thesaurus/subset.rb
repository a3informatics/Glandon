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

  #Find Managed Concept. Find the managed concept 
  def find_mc
      objects = []
      query_string = %Q{
        SELECT DISTINCT ?s ?p ?o WHERE {
          #{self.uri.to_ref} (^th:isOrdered) ?s .
          ?s ?p ?o
        }
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      # return nil if query_results.empty?
      query_results.by_subject.each do |subject, triples|
        objects << Thesaurus::SubsetMember.from_results(Uri.new(uri: subject), triples)
      end
      return objects.first if objects.count == 1
      Errors.application_error(self.class.name, __method__.to_s, "Multiple MC found.")
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
      if !sm.next_member.nil?
        self.add_link(:members, sm.next_member.uri)
      end
    else 
      prev_sm.delete_link(:member_next, sm.uri)
      if !sm.next_member.nil?
        prev_sm.add_link(:member_next, sm.next_member.uri)
      end
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

  # List Pagination. Get the list in pagination manner
  #
  # @params [Hash] params the params hash
  # @option params [String] :offset the offset to be obtained
  # @option params [String] :count the count to be obtained
  # @return [Array] array of hashes containing the child data
  def list_pagination(params)
    objects = []
    if !self.members.nil?
      query_string = %Q{
        SELECT ?m ?s ?ordinal
        {
          ?m th:item ?s
          {
            SELECT ?m (COUNT(?mid) as ?ordinal) WHERE {
              #{self.uri.to_ref} th:members/th:memberNext* ?mid . 
              ?mid th:memberNext* ?m .
              ?m th:item ?e
            } 
            GROUP BY ?m ?e
          }
        } ORDER BY ?ordinal OFFSET #{params[:offset]} LIMIT #{params[:count]}
      }
      query_results = Sparql::Query.new.query(query_string, "", [:th])
      result_set = query_results.by_object_set([:m, :s, :ordinal])
      objects = Thesaurus::UnmanagedConcept.children_set(result_set.map{|x| x[:s]})
      uri_map = result_set.map {|x| [x[:s].to_s, x] }.to_h
      objects.each do |object| 
        object[:ordinal] = uri_map[object[:uri]][:ordinal].to_i
        object[:member_id] = uri_map[object[:uri]][:m].to_id
      end
    end
      objects
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
      if !sm.next_member.nil?
        prev_sm.add_link(:member_next, sm.next_member.uri)
      end
      old_first = self.members
      self.delete_link(:members, old_first)
      self.add_link(:members, sm.uri)
      if !sm.next_member.nil?
        sm.delete_link(:member_next, sm.next_member.uri)
      end
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
        if prev_sm.nil? #Moving the first element
          self.delete_link(:members, sm.uri)
          self.add_link(:members, sm.next_member.uri)
          sm.delete_link(:member_next, sm.next_member.uri)
          if !to_after_sm.next_member.nil?
            sm.add_link(:member_next, to_after_sm.next_member.uri)
          end
          if !sm.next_member.nil?
            sm.add_link(:member_next, to_after_sm.next_member.uri)
            to_after_sm.delete_link(:member_next, to_after_sm.next_member.uri)
          end
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
    end
    transaction_execute
  end

end