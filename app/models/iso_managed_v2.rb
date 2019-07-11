# ISO Managed (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoManagedV2 < IsoConceptV2

  configure rdf_type: "http://www.assero.co.uk/ISO11179Types#AdministeredItem"

  object_property :has_state, cardinality: :one, model_class: "IsoRegistrationStateV2"
  object_property :has_identifier, cardinality: :one, model_class: "IsoScopedIdentifierV2"
  data_property :origin
  data_property :change_description
  data_property :creation_date
  data_property :last_change_date
  data_property :explanatory_comment

  validates_with Validator::Field, attribute: :origin, method: :valid_markdown?
  validates_with Validator::Field, attribute: :change_description, method: :valid_markdown?
  validates_with Validator::Field, attribute: :explanatory_comment, method: :valid_markdown?

  # Constants
  C_CLASS_NAME = self.name
  C_HAS_STATE = Uri.new(uri: "http://www.assero.co.uk/ISO11179Types#hasState")
  C_HAS_IDENTIFER = Uri.new(uri: "http://www.assero.co.uk/ISO11179Types#hasIdentifier")
  C_RA_NAMESPACE = Uri.new(uri: "http://www.assero.co.uk/ISO11179Registration#raNamespace")
  C_HAS_SCOPE = Uri.new(uri: "http://www.assero.co.uk/ISO11179Identification#hasScope")
  
  # Version
  #
  # @return [string] The version
  def version
    return self.has_identifier.version
  end

  # Version Label
  #
  # @return [string] The version label
  def version_label
    return self.has_identifier.version_label
  end

  # Semantic Version
  #
  # @return [SemanticVersion] The semantic version
  def semantic_version
    return self.has_identifier.semantic_version
  end

  # Return the identifier
  #
  # @return [string] The identifier.
  def identifier
    return self.has_identifier.identifier
  end

  # Latest version
  #
  # @return [Boolean] Returns true of latest
  def latest?
    return self.version == IsoScopedIdentifierV2.latest_version(self.identifier, self.has_state.by_authority)
  end

  # Later Version
  #
  # @param version [Integer] the version being compared against
  # @return [Boolean] true if the item has a version later than that specified
  def later_version?(version)
    return self.has_identifier.later_version?(version)
  end
  
  # Earlier Version
  #
  # @param version [Integer] the version being compared against
  # @return [Boolean] true if the item has a version earlier than that specified
  def earlier_version?(version)
    return self.has_identifier.earlier_version?(version)
  end
  
  # Same Version
  #
  # @return [Boolean] Returns true if the item has the same version as that specified
  def same_version?(version)
    return self.has_identifier.same_version?(version)
  end
  
  # Return the owner
  #
  # @return [IsoRegistrationAuthorityV2] The owner authority object.
  def owner
    self.has_state.by_authority
  end

  def owner_short_name
    return owner.ra_namespace.short_name
  end

  # Determine if the object is owned by this repository
  #
  # @return [Boolean] True if owned, false otherwise
  def owned?
    ra_owner = IsoRegistrationAuthority.owner
    return self.owner.uri == ra_owner.uri
  end

  # Return the registration status
  #
  # @return [string] The status
  def registration_status
    return "na" if self.has_state.nil?
    return self.has_state.registration_status
  end

  # Checks if item is regsitered
  #
  # @return [Boolean] True if registered, false otherwise
  def registered?
    return false if self.has_state.nil?
    return self.has_state.registered?
  end

  # Determines if edit is allowed.
  #
  # @return [Boolean] True if edit is permitted, false otherwise.
  def edit?
    return false if self.has_state.nil?
    return self.has_state.edit? && self.owned?
  end

  # Determines if the item can be deleted.
  #
  # @return [Boolean] Ture if delete allowed, false otherwise.
  def delete?
    return false if self.has_state.nil?
    return self.has_state.delete?
  end

  # Determines if a new version can be created
  #
  # @return [Boolean] True if can be created, false otherwise
  def new_version?
    return false if self.has_state.nil?
    return self.has_state.new_version?
  end

  # Get the state after an edit.
  #
  # @return [string] The state.
  def state_on_edit
    return IsoRegistrationState.no_state if self.has_state.nil?
    return self.has_state.state_on_edit
  end

  # Checks if item can be the current item.
  #
  # @return [Boolean] True if can be current, false otherwise. 
  def can_be_current?
    return false if self.has_state.nil?
    return self.has_state.can_be_current?
  end

  # Return the next version
  #
  # @return [integer] the next version
  def next_version
    self.has_identifier.next_version
  end

  # Return the next version
  #
  # @param identifier [String] the identifier being checked
  # @param scope [IsoNamespace] the scope within which the indentifier is being checked
  # @return [integer] the next version
  def self.next_version(identifier, scope)
    IsoScopedIdentifierV2.next_version(identifier, scope)
  end

  # Return the next semantic version
  #
  # @return [SemanticVersion] the next semantic version
  def next_semantic_version
    self.has_identifier.next_semantic_version
  end

  # Return the first version
  #
  # @return [string] The first version
  def first_version
    IsoScopedIdentifierV2.first_version
  end

  # Is the item the current item.
  #
  # @return [Boolean] True if current, false otherwise
  def current?
    return false if self.has_state.nil?
    return self.has_state.current?
  end

  # Find
  #
  # @param [Uri|id] the identifier, either a URI or the id
  # @return [Object] a class object.
  # @param full [Boolean] all child triples if set true, otherwise just the top level concept
  # @return [object] The object.
  def self.find(id, full=true)  
    uri = id.is_a?(Uri) ? id : Uri.new(id: id)
    parts = []
    x = subject_set(full)
    exclude_clause = x[:exclude].blank? ? "" : " MINUS { ?s (#{x[:exclude]}) ?o }"
    parts << "{ BIND (#{uri.to_ref} as ?s) . ?s ?p ?o #{exclude_clause}}" 
    x[:include].each {|p| parts << "{ #{uri.to_ref} (#{p})+ ?o1 . BIND (?o1 as ?s) . ?s ?p ?o }" }
    query_string = "SELECT DISTINCT ?s ?p ?o ?e WHERE {{ #{parts.join(" UNION\n")} }}"
    results = Sparql::Query.new.query(query_string, uri.namespace, [:isoI, :isoR])
    raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
    from_results_recurse(uri, results.by_subject)
  end

  # History. Find the history for a given identifier within a scope
  #
  # @rdfType [string] The RDF type
  # @ns [string] The namespace
  # @params [hash] {:identifier, :scope_id}
  # @return [array] An array of objects.
  def self.history(params)    
    parts = []
    results = []
    base =  "?e rdf:type #{rdf_type.to_ref} . " +
            "?e isoT:hasIdentifier ?si . " +
            "?si isoI:identifier '#{params[:identifier]}' . " +
            "?si isoI:hasScope #{params[:scope].uri.to_ref} . " 
    parts << "  { ?e ?p ?o . FILTER (strstarts(str(?p), \"http://www.assero.co.uk/ISO11179\")) BIND (?e as ?s) }" 
    parts << "  { ?si ?p ?o . BIND (?si as ?s) }"  
    parts << "  { #{params[:scope].uri.to_ref} ?p ?o . BIND (#{params[:scope].uri.to_ref} as ?s)}" 
    parts << "  { ?e isoT:hasState ?s . ?s ?p ?o }" 
    query_string = "SELECT ?s ?p ?o ?e WHERE { #{base} { #{parts.join(" UNION\n")} }}"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    by_subject = query_results.by_subject
    query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri| 
      item = from_results_recurse(uri, by_subject)
      item.has_state.by_authority = params[:scope]
      item.has_identifier.has_scope = params[:scope].ra_namespace
      results << item
    end
    results.sort_by{|x| x.version}
  end

  def self.history_pagination(params)
    triple_count = 28
    count = params[:count].to_i * triple_count 
    offset = params[:offset].to_i * triple_count 
    parts = []
    results = []
    base =  "?e rdf:type #{rdf_type.to_ref} . " +
            "?e isoT:hasIdentifier ?si . " +
            "?si isoI:identifier '#{params[:identifier]}' . " +
            "?si isoI:version ?v . " +
            "?si isoI:hasScope #{params[:scope].uri.to_ref} . " 
    parts << "  { ?e ?p ?o . FILTER (strstarts(str(?p), \"http://www.assero.co.uk/ISO11179\")) BIND (?e as ?s) }" 
    parts << "  { ?si ?p ?o . BIND (?si as ?s) }"  
    parts << "  { #{params[:scope].uri.to_ref} ?p ?o . BIND (#{params[:scope].uri.to_ref} as ?s)}" 
    parts << "  { ?e isoT:hasState ?s . ?s ?p ?o }" 
    query_string = "SELECT ?s ?p ?o ?e ?v WHERE { #{base} { #{parts.join(" UNION\n")} }} ORDER BY (?v) LIMIT #{count} OFFSET #{offset}"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    by_subject = query_results.by_subject
    query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri| 
      item = from_results_recurse(uri, by_subject)
      item.has_state.by_authority = params[:scope]
      item.has_identifier.has_scope = params[:scope].ra_namespace
      results << item
    end
    results
  end

  # Managed Children Pagination. Get managed children by page
  #
  # @params [Hash] params a hash of parameters
  # @params params [String] :offset the start offset of items to be returned
  # @params params [String] :count the count of items to be returned
  # @return [Hash] a hash containing six objects, start & end, forward & back by step, forward and back by window
  def managed_children_pagination(params)
    results = []
    query_string = block_given? ? yield(params) : managed_children_pagination_query(params)
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT, :bo, :th])
    by_subject = query_results.by_subject
    query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri| 
      item = self.class.children_klass.referenced_klass.from_results_recurse(uri, by_subject)
      results << item
    end
    results
  end

  # Children Pagination. Get unmanaged children by page
  #
  # @params [Hash] params a hash of parameters
  # @params params [String] :offset the start offset of items to be returned
  # @params params [String] :count the count of items to be returned
  # @return [Hash] a hash containing six objects, start & end, forward & back by step, forward and back by window
  def children_pagination(params)
    results = []
    query_string = block_given? ? yield(params) : children_pagination_query(params)
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT, :bo])
    by_subject = query_results.by_subject
    query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri| 
      item = self.class.children_klass.from_results_recurse(uri, by_subject)
      results << item
    end
    results
  end

  def self.latest(params)
    results = history(params)
    results.empty? ? nil : results.last
  end

  # Forward Backward. Provides URIs for mving through the history
  #
  # @params [Integer] step the step to be taken, probably best set to 1
  # @params [Integer] window the window size; the number being displayed
  # @return [Hash] a hash containing six objects, start & end, forward & back by step, forward and back by window
  def forward_backward(step, window)
    result = {start: nil, backward_single: nil, backward_multiple: nil, forward_single: nil, forward_multiple: nil, end: nil}
    history_result = self.class.history(scope: owner, identifier: self.identifier)
    return result if history_result.empty?
    start_stop = 0
    end_stop = history_result.count - window
    my_index = history_result.index {|x| x.uri == self.uri}
    result[:start] = history_result[start_stop] if my_index > start_stop
    result[:backward_single] = history_result[backward(my_index, step, start_stop)] if my_index > start_stop
    result[:backward_multiple] = history_result[backward(my_index, step, start_stop)] if my_index > start_stop
    result[:forward_single] = history_result[forward(my_index, step, end_stop)] if my_index < end_stop
    result[:forward_multiple] = history_result[forward(my_index, window, end_stop)] if my_index < end_stop
    result[:end] = history_result[end_stop] if my_index < end_stop
    result
  end

  # Update the item
  #
  # @params [Hash] The parameters {:explanatoryComment, :changeDescription, :origin}
  # @raise [Exceptions::UpdateError] if an error occurs during the update
  # @return null
  def update(params)  
    Sparql::Update.new.sparql_update(update_query(params), self.rdf_type.namespace, [:isoT])
  end

  # Set URIs. Sets the URIs for the managed item and all children
  #
  # @param [IsoRegistrationAuthority] ra the registration authority under which the item is being registered
  # @return [Void] no return
  def set_uris(ra)
    generate_uri(Uri.new(authority: ra.ra_namespace.authority, identifier: self.identifier, version: self.version))
  end

  # Set Intial. Sets the SI and RS fields to the initial values for a new item.
  #
  # @param [String] indentifier the identifier
  # @return [Void] no return
  def set_initial(identifier)
    ra = IsoRegistrationAuthority.owner
    self.has_identifier = IsoScopedIdentifierV2.from_h(identifier: identifier, version: 1, semantic_version: "0.0.1", has_scope: ra)
    self.has_state = IsoRegistrationStateV2.from_h(by_authority: ra, registration_status: "Incomplete", previous_state: "Incomplete")
    self.last_change_date = Time.now
    set_uris(ra)
  end

  # Set Import. Sets the key parameters for a managed item.
  #
  # @param [Hash] params the params hash
  # @option params [String] :label the items's label
  # @option params [String] :identifier the items's identifier
  # @option params [String] :version_label the items's version label
  # @option params [String] :semantic_version the items's semantic version
  # @option params [String] :version the items's version (integer as a string)
  # @option params [String] :date the items's release date
  # @option params [Integer] :ordinal the ordinal for the item
  # @return [Void] no return
  def set_import(params)
    ra = self.class.owner
    self.label = params[:label] if self.label.blank?
    self.has_identifier = IsoScopedIdentifierV2.from_h(identifier: params[:identifier], version: params[:version], version_label: params[:version_label], 
      semantic_version: params[:semantic_version], has_scope: ra)
    self.has_state = IsoRegistrationStateV2.from_h(by_authority: ra, registration_status: IsoRegistrationStateV2.released_state, 
      previous_state: IsoRegistrationStateV2.released_state)
    self.creation_date = params[:date].to_time_with_default
    self.last_change_date = params[:date].to_time_with_default
    set_uris(ra)
  end 

private

  # Standard managed children pagination query
  def managed_children_pagination_query(params)
    triple_count = 28
    count = params[:count].to_i * triple_count 
    offset = params[:offset].to_i * triple_count 
    %Q{SELECT ?s ?p ?o ?e ?v WHERE
{
  #{self.uri.to_ref} #{self.class.children_predicate.to_ref} ?r . 
  ?r bo:reference ?e .
  ?r bo:ordinal ?v .
  ?e isoT:hasIdentifier ?si .
  ?si isoI:hasScope ?ra .
  ?e isoT:hasState ?rs .
  {
    { ?e ?p ?o . FILTER (strstarts(str(?p), \"http://www.assero.co.uk/ISO11179\")) BIND (?e as ?s) } UNION
    { ?si ?p ?o . BIND (?si as ?s) } UNION
    { ?ra ?p ?o . BIND (?ra as ?s) } UNION
    { ?rs ?p ?o . BIND (?rs as ?s) }
  }
} ORDER BY (?v) LIMIT #{count} OFFSET #{offset} 
}
  end

  # Standard unmanaged children pagination query
  def children_pagination_query(params)
    count = params[:count].to_i
    offset = params[:offset].to_i
    uris = children.map{|x| x.uri.to_ref}[offset..(offset+count-1)].join(" ")
    %Q{SELECT DISTINCT ?s ?p ?o ?e WHERE
{
  VALUES ?e { #{uris} }
  ?e ?p ?o . 
  BIND (?e as ?s)
} 
}
  end

  def forward(current, step, end_stop)
    return (current + step) < end_stop ? (current + step) : end_stop
  end

  def backward(current, step, end_stop)
    return (current - step) > end_stop ? (current - step) : end_stop
  end

  # The update query
  def update_query(params)
    "DELETE \n" +
      "{ \n" +
      " #{self.uri.to_ref} isoT:explanatoryComment ?a . \n" +
      " #{self.uri.to_ref} isoT:changeDescription ?b . \n" +
      " #{self.uri.to_ref} isoT:origin ?c . \n" +
      " #{self.uri.to_ref} isoT:lastChangeDate ?d . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " #{self.uri.to_ref} isoT:explanatoryComment \"#{SparqlUtility::replace_special_chars(params[:explanatory_comment])}\"^^xsd:string . \n" +
      " #{self.uri.to_ref} isoT:changeDescription \"#{SparqlUtility::replace_special_chars(params[:change_description])}\"^^xsd:string . \n" +
      " #{self.uri.to_ref} isoT:origin \"#{SparqlUtility::replace_special_chars(params[:origin])}\"^^xsd:string . \n" +
      " #{self.uri.to_ref} isoT:lastChangeDate \"#{SparqlUtility::replace_special_chars(Time.now.iso8601)}\"^^xsd:dateTime . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " #{self.uri.to_ref} isoT:explanatoryComment ?a . \n" +
      " #{self.uri.to_ref} isoT:changeDescription ?b . \n" +
      " #{self.uri.to_ref} isoT:origin ?c . \n" +
      " #{self.uri.to_ref} isoT:lastChangeDate ?d . \n" +
      "}"
  end

  # Relationship set, array of predicates.
  def self.subject_set(full)
    x = properties_metadata_class
    {include: x.managed_paths, exclude: x.excluded_relationships}
  end

end