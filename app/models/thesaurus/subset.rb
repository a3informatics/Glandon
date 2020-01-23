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
      return nil if query_results.empty?
      query_results.by_subject.each do |subject, triples|
        objects << Thesaurus::ManagedConcept.from_results(Uri.new(uri: subject), triples)
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
    mc = self.find_mc
    last_sm = self.last
    if last_sm.nil? #Add the first member
     self.add_link(:members, sm.uri)
    else #Add the new member to the last position 
     last_sm.add_link(:member_next, sm.uri)
    end
    mc.add_link(:narrower, sm.item) 
    transaction_execute
    sm
  end

  # Remove. Remove a subset member of the Subset
  #
  # @param subset_member_id [String] the identifier of the subset member to be removed
  def remove(subset_member_id)
    transaction_begin
    sm = Thesaurus::SubsetMember.find(subset_member_id)
    mc = self.find_mc
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
    mc.delete_link(:narrower, sm.item)
    sm.delete
    transaction_execute
  end

  # List URIs. Get the complete subset list as a set of ordered URIs
  #
  # @return [Array] array of hashes, each hash the uri and ordinal of the list members.
  def list_uris
    objects = []
    query_string = %Q{
      SELECT ?uri ?ordinal
      {
        ?m th:item ?uri
        {
          SELECT ?m (COUNT(?mid) as ?ordinal) WHERE {
            #{self.uri.to_ref} th:members/th:memberNext* ?mid . 
            ?mid th:memberNext* ?m .
          } 
          GROUP BY ?m
        }
      } ORDER BY ?ordinal 
    }
    query_results = Sparql::Query.new.query(query_string, "", [:th])
    query_results.by_object_set([:uri, :ordinal])
  end

  # Clone. Clone the subset
  #
  # @return [Thesarus::Subset] the cloned object. Included clone of the members
  def clone
    cloned_members = []
    object = super
    list_uris.each {|items| cloned_members << Thesaurus::SubsetMember.new({item: items[:uri], uri: Thesaurus::SubsetMember.create_uri(self.uri)})}
    return object if cloned_members.empty?
    cloned_members.each_with_index do |cloned_member, index|
      next_item = ordinal = index + 1
      cloned_member.member_next = ordinal == cloned_members.count ? nil : cloned_members[next_item]
    end
    object.members = cloned_members.first
    object
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


  # Delete. Delete the subset
  #
  # @return [integer] the number of objects deleted (always 1 if no exception)
    def delete_subset
      query_string = %Q{
        DELETE {?s ?p ?o} WHERE 
        {
            {#{self.uri.to_ref} (th:members/th:memberNext*) ?s.
            ?s ?p ?o }   
        UNION
          { 
            #{self.uri.to_ref} ?p ?o.
            BIND (#{self.uri.to_ref} as ?s)
          }
        }
      }
      results = Sparql::Update.new.sparql_update(query_string, "", [:th])
      1
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

  # Add multiple. 
  #
  # @params [Hash] params the params hash
  # @option params [String] :offset the offset to be obtained
  # @option params [String] :count the count to be obtained
  # @return [Array] array of hashes containing the child data
  def add_multiple(arr)
      # sm = []
      mc = self.find_mc
      last_sm = self.last
      # arr.each |x| do
      #   sm << Thesaurus::SubsetMember.create({item: Uri.new(id: x.id), uri: Thesaurus::SubsetMember.create_uri(self.uri)})
      # end
      subset_members = arr.map{|x| Thesaurus::SubsetMember.create({item: Uri.new(id: x.to_id), uri: Thesaurus::SubsetMember.create_uri(self.uri)})}

      subset_members[0].member_next = subset_members[1]

      subset_members.each do |sm|
        last_sm = self.last
        if last_sm.nil? #Add the first member
          self.add_link(:members, sm.uri)
        else #Add the new member to the last position 
          last_sm.add_link(:member_next, sm.uri)
        end
      end

      subset_members.each do |sm|
        mc.add_link(:narrower, sm.item) 
      end

      # uris = []
      # (1..arr.length).each do |index|
      #   item = Thesaurus::SubsetMember.create({item: Uri.new(id: x.id), uri: Thesaurus::SubsetMember.create_uri(self.uri)})
      #   item.uri = Uri.new(uri: "http://www.assero.co.uk/XXX/ITEM/V#{index}")
      #   item.label = "Item #{index}"
      #   item.set_import(identifier: "ITEM", version_label: "#{index}", semantic_version: "1.0.0", version: "#{index}", date: "2019-01-01", ordinal: 1)
      #   sparql = Sparql::Update.new  
      #   item.to_sparql(sparql, true)
      #   sparql.upload
      #   uris[index-1] = item.uri
      # end 


    # transaction_begin
    # sm = Thesaurus::SubsetMember.create({item: Uri.new(id: uc_id), uri: Thesaurus::SubsetMember.create_uri(self.uri)})
    # mc = self.find_mc
    # last_sm = self.last
    # if last_sm.nil? #Add the first member
    #  self.add_link(:members, sm.uri)
    # else #Add the new member to the last position 
    #  last_sm.add_link(:member_next, sm.uri)
    # end
    # mc.add_link(:narrower, sm.item) 
    # transaction_execute
    # sm


    #   sparql = Sparql::Update.new
    #   sparql.default_namespace(self.uri.namespace)
    #   # @todo only supports generated identifiers currently
    #   synonyms.each do |syn|
    #     child = Thesaurus::UnmanagedConcept.from_h({
    #       # uri: Thesaurus::UnmanagedConcept.generate_uri(self),
    #       identifier: Thesaurus::UnmanagedConcept.new_identifier,
    #       notation: syn.label,
    #       label: pt.label ,
    #       preferred_term: pt,
    #       synonym: synonyms,
    #       definition: object.definition,
    #       tagged: object.tagged 
    #     })
    #     child.generate_uri(self.uri)
    #     child.to_sparql(sparql)
    #     sparql.add({uri: self.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "narrower"}, {uri: child.uri})
    #   end
    #   filename = sparql.to_file
    #   sparql.create
    #   self.narrower_objects
  end

  # Remove all. Removes all the subset members and narrower from Subset
  #
  def remove_all
    query_string = %Q{
        DELETE 
        {
          ?s ?p ?o
        } 
        WHERE 
        {
          {
            #{self.uri.to_ref} (th:members/th:memberNext*) ?s .
            ?s ?p ?o .
          }     
          UNION
          { 
            #{self.uri.to_ref} (^th:isOrdered) ?s .
            ?s th:narrower ?o
            BIND ( th:narrower as ?p ) .
          } 
        }
      }
      partial_update(query_string, [:th])
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
          if to_after_sm.next_member.nil?
            to_after_sm.add_link(:member_next, sm.uri) 
          else
            sm.add_link(:member_next, to_after_sm.next_member.uri)
            to_after_sm.delete_link(:member_next, to_after_sm.next_member.uri)
            to_after_sm.add_link(:member_next, sm.uri)
          end 
        end
      end
    end
    transaction_execute
  end

end