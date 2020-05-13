# SKOS Ordered Collection
#
# @author Dave Iberson-Hurst
# @since 2.40.0
module SKOS::OrderedCollection

  # Assumes :members declared
  # object_property :members, cardinality: :one, model_class: "Thesaurus::SubsetMember"

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    # No class methods as yet.

  end

  # Last. Find last item in the list
  #
  # @return [Object] th last item as an instance of the configured class
  def last
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (th:members/th:memberNext*) ?s .
        FILTER NOT EXISTS { ?s th:memberNext ?c }
        ?s ?p ?o
      }
    }
    Sparql::Query.new.query(query_string, "", [:th]).single_subject_as(target_klass)
  end

  # Parent. Find the parent of the ordered collection
  #
  # @return [Object] the parent object
  def parent
    objects = []
    query_string = %Q{
      SELECT DISTINCT ?s ?p ?o WHERE {
        #{self.uri.to_ref} (^th:isOrdered) ?s .
        ?s ?p ?o
      }
    }
    Sparql::Query.new.query(query_string, "", [:th]).single_subject_as(target_klass)
  end

  # Remove. Remove a subset member of the Subset
  #
  # @param subset_member_id [String] the identifier of the subset member to be removed
  def remove(subset_member_id)
    sm = member_klass.find(subset_member_id)
    mc = parent
    prev_sm = sm.previous_member
    delete_link_clauses = []
    add_link_clause = ""
    if prev_sm.nil?
      delete_link_clauses << "#{self.uri.to_ref} th:members #{sm.uri.to_ref}"
      add_link_clause = "#{self.uri.to_ref} th:members #{sm.next_member.uri.to_ref} ." unless sm.next_member.nil?
    else
      delete_link_clauses << "#{prev_sm.uri.to_ref} th:memberNext #{sm.uri.to_ref}"
      add_link_clause = "#{prev_sm.uri.to_ref} th:memberNext #{sm.next_member.uri.to_ref} ." unless sm.next_member.nil?
    end
    delete_link_clauses << "#{mc.uri.to_ref} th:narrower #{sm.item.to_ref}"
    query_string = %Q{
    DELETE DATA
    {
      #{delete_link_clauses.join(" .\n")}
    };
    INSERT DATA
    {
      #{add_link_clause} 
    };
    DELETE {?s ?p ?o} WHERE 
    { 
      #{sm.uri.to_ref} ?p ?o . 
      BIND (#{sm.uri.to_ref} as ?s) 
    }}
    results = Sparql::Update.new.sparql_update(query_string, "", [:th])
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
    object.uri = create_uri(self.class.base_uri)
    list_uris.each do |items| 
      item = member_klass.new(item: items[:uri])
      item.uri = item.create_uri(object.uri)
      cloned_members << item
    end
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
        objects << member_klass.from_results(Uri.new(uri: subject), triples)
      end
      objects
    end
  
  end

  # Delete. Delete the subset
  #
  # @return [integer] the number of objects deleted (always 1 if no exception)
  def delete
    query_string = %Q{
      DELETE {?s ?p ?o} WHERE 
      {
        {
          #{self.uri.to_ref} (th:members/th:memberNext*) ?s.
          ?s ?p ?o 
        }   
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
      query_string = %Q{
        SELECT ?m ?s ?ordinal
        {
          FILTER (?ordinal > 0)
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
      objects = parent_klass.children_set(result_set.map{|x| x[:s]})
      uri_map = result_set.map {|x| [x[:s].to_s, x] }.to_h
      objects.each do |object| 
        object[:ordinal] = uri_map[object[:uri]][:ordinal].to_i
        object[:member_id] = uri_map[object[:uri]][:m].to_id
      end
    objects
  end

  # Add. Add new subset members to the Subset
  #
  # @param arr [Array] Array of the ids of the unmanaged concept to be added to the Subset
  # @return [Object] the created Subset Member
  def add(arr)
    subset_members = []
    sparql = Sparql::Update.new
    sparql.default_namespace(self.uri.namespace)
    mc = self.find_mc
    arr.each do |x|
      member = member_klass.new(item: Uri.new(id: x))
      member.uri = member.create_uri(mc.uri)
      subset_members << member
      member.to_sparql(sparql)
      sparql.add({uri: mc.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "narrower"}, {uri: member.item})
    end
    last_sm = self.last
    subset_members[0..-2].each_with_index do |sm, index|
      sparql.add({uri: subset_members[index].uri}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "memberNext"}, {uri: subset_members[index+1].uri})
    end
    last_sm.nil? ? sparql.add({uri: self.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "members"}, {uri: subset_members.first.uri}) : sparql.add({uri: last_sm.uri}, {namespace: Uri.namespaces.namespace_from_prefix(:th), fragment: "memberNext"}, {uri: subset_members.first.uri})
    #filename = sparql.to_file
    sparql.create
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
  # @param this_id [String] the id of the subset member to be moved after
  # @param to_after_id [String] the id of the subset member to which the subset member moves after
  def move_after(this_id, to_after_id=nil)
    query_string = ""
    this = Uri.new(id: this_id)
    if to_after_id.nil?
      # Moving to front of the list
      query_string = %Q{
        DELETE 
        {
          #{self.uri.to_ref} th:members ?first .
          #{this.to_ref} th:memberNext ?next .
          ?previous th:memberNext #{this.to_ref} .
        }
        INSERT
        {
          #{self.uri.to_ref} th:members #{this.to_ref} .
          #{this.to_ref} th:memberNext ?first .
          ?previous th:memberNext ?next .
        }
        WHERE 
        {
          #{self.uri.to_ref} th:members ?first .
          OPTIONAL {#{this.to_ref} th:memberNext ?next}
          OPTIONAL {#{this.to_ref} ^th:memberNext ?previous}
        }
      }
    elsif self.members == this
      # Moving from front of the list
      after = Uri.new(id: to_after_id)
      query_string = %Q{
        DELETE 
        {
          #{self.uri.to_ref} th:members ?first .
          #{this.to_ref} th:memberNext ?next .
          #{after.to_ref} th:memberNext ?new_next . 
        }
        INSERT
        {
          #{self.uri.to_ref} th:members ?next .
          #{after.to_ref} th:memberNext #{this.to_ref} . 
          #{this.to_ref} th:memberNext ?new_next . 
        }
        WHERE 
        {
          #{self.uri.to_ref} th:members #{this.to_ref} .
          OPTIONAL {#{after.to_ref} th:memberNext ?new_next}
          OPTIONAL {#{this.to_ref} th:memberNext ?next}
        }
      }
    else
      # Moving from other postion
      after = Uri.new(id: to_after_id)
      query_string = %Q{
        DELETE 
        {
          #{this.to_ref} th:memberNext ?next .
          #{after.to_ref} th:memberNext ?new_next . 
          ?previous th:memberNext #{this.to_ref} .
        }
        INSERT
        {
          ?previous th:memberNext ?next.
          #{after.to_ref} th:memberNext #{this.to_ref} . 
          #{this.to_ref} th:memberNext ?new_next . 
        }
        WHERE 
        {
          OPTIONAL {#{after.to_ref} th:memberNext ?new_next}
          OPTIONAL {#{this.to_ref} th:memberNext ?next}
          OPTIONAL {#{this.to_ref} ^th:memberNext ?previous}
        }
      }
    end
    results = Sparql::Update.new.sparql_update(query_string, "", [:th])
  end

private

  # Obtain the target class
  def target_klass
    self.properties.property(:members).klass
  end

end