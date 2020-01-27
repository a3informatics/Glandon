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
  validates_with Validator::Klass, property: :has_identifier
  validates_with Validator::Klass, property: :has_state

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

  # Return the scoped identifier
  #
  # @return [String] the scoped identifier.
  def scoped_identifier
    return self.has_identifier.identifier
  end

  # Latest version
  #
  # @return [Boolean] Returns true of latest
  def latest?
    return self.version == IsoScopedIdentifierV2.latest_version(self.scoped_identifier, self.has_identifier.has_scope)
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

  def scope
    return self.has_identifier.has_scope
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

  # Is Owned By CDISC?
  #
  # @return [Boolean] True if owned, false otherwise
  def is_owned_by_cdisc?
    cdisc_ns = IsoRegistrationAuthority.cdisc_scope
    return self.owner.ra_namespace.uri == cdisc_ns.uri
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

  # Supporting Edit? Can the item be edited for supporting information, e.g. tags, change notes etc.
  #
  # @return [Boolean] true if edit permitted, false otherwise
  def supporting_edit?
    self.owned?
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

  # Previous Release
  #
  # @return
  def previous_release
    results = state_and_semantic_version(identifier: self.has_identifier.identifier, scope: self.scope)
    raise Errors::NotFoundError.new("Failed to find previous semantic versions for #{self.uri}.") if results.empty?
    return SemanticVersion.first.to_s if results.count == 1 # If only one item force to base (first) version
    item = results.find {|x| x[:state] == IsoRegistrationStateV2.released_state}
    item.nil? ? results.last[:semantic_version] : item[:semantic_version]
  end

  # Release
  #
  # @param [Symbol] release (:major, :minor, :patch)
  # @return [Boolean] true if update was made.
  def release(release)
    if !self.has_state.update_release?
      self.errors.add(:base, "The release cannot be updated in the current state")
      return false
    elsif !self.latest?
      self.errors.add(:base, "Can only modify the latest release")
      return false
    else
      sv = SemanticVersion.from_s(previous_release)
      case release
        when :major
          sv.increment_major
        when :minor
          sv.increment_minor
        when :patch
          sv.increment_patch
        else
          self.errors.add(:base, "The release request type was invalid")
          return false
      end
      if uris[:uris].length <= 1
        si = self.has_identifier
        si.update(semantic_version: sv.to_s)
        si.save
      else
        update_previous_releases(uris: uris[:uris], semantic_version: sv.to_s)
      end
    end
    true
  end

  # Find With Properties. Finds the version management info and data properties for the item. Does not fill in the object properties.
  #
  # @param [Uri|id] the identifier, either a URI or the id
  # @return [object] The object.
  def self.find_with_properties(id)
    uri = id.is_a?(Uri) ? id : Uri.new(id: id)
    parts = []
    parts << "  { #{uri.to_ref} isoT:hasIdentifier ?o . BIND (<isoT:hasIdentifier> as ?p) . BIND (#{uri.to_ref} as ?s) }"
    parts << "  { #{uri.to_ref} isoT:hasState ?o . BIND (<isoT:hasState> as ?p) . BIND (#{uri.to_ref} as ?s) }"
    parts << "  { #{uri.to_ref} isoT:hasIdentifier ?s . ?s ?p ?o }"
    parts << "  { #{uri.to_ref} isoT:hasState ?s . ?s ?p ?o }"
    property_relationships.map.each do |relationship|
      parts << "{ #{uri.to_ref} #{relationship[:predicate].to_ref} ?o . BIND ( #{relationship[:predicate].to_ref} as ?p) . BIND (#{uri.to_ref} as ?s)}"
    end
    query_string = "SELECT ?s ?p ?o ?e WHERE { { #{parts.join(" UNION\n")} }}"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if query_results.empty?
    item = from_results_recurse(uri, query_results.by_subject)
    ns_uri = item.has_identifier.has_scope
    item.has_identifier.has_scope = IsoNamespace.find(ns_uri)
    ra_uri = item.has_state.by_authority
    item.has_state.by_authority = IsoRegistrationAuthority.find(ra_uri)
    ns_uri = item.has_state.by_authority.ra_namespace
    item.has_state.by_authority.ra_namespace = IsoNamespace.find(ns_uri)
    item
  end

  # Find Full. Full find of the managed item. Will find all children via paths that are not excluded.
  #
  # @param [Uri|id] the identifier, either a URI or the id
  # @return [IsoManagedV2] The managed item object.
  def self.find_full(id)
    uri = id.is_a?(Uri) ? id : Uri.new(id: id)
    parts = []
    exclude = excluded_read_relationships
    exclude_clause = exclude.blank? ? "" : " MINUS { ?s (#{exclude.join("|")}) ?o }"
    parts << "{ BIND (#{uri.to_ref} as ?s) . ?s ?p ?o #{exclude_clause}}"
    read_paths.each {|p| parts << "{ #{uri.to_ref} (#{p})+ ?o1 . BIND (?o1 as ?s) . ?s ?p ?o }" }
    query_string = "SELECT DISTINCT ?s ?p ?o ?e WHERE {{ #{parts.join(" UNION\n")} }}"
    results = Sparql::Query.new.query(query_string, uri.namespace, [:isoI, :isoR])
    raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if results.empty?
    from_results_recurse(uri, results.by_subject)
  end

  # Find Minimum. Finds the minimun amount of info for an Managed Item. Use this for quick finds.
  #
  # @param [Uri|id] the identifier, either a URI or the id
  # @return [object] The object.
  def self.find_minimum(id)
    uri = id.is_a?(Uri) ? id : Uri.new(id: id)
    parts = []
    parts << "  { #{uri.to_ref} ?p ?o . FILTER (strstarts(str(?p), \"http://www.assero.co.uk/ISO11179\")) BIND (#{uri.to_ref} as ?s) }"
    parts << "  { #{uri.to_ref} isoT:hasIdentifier ?s . ?s ?p ?o }"
    parts << "  { #{uri.to_ref} isoT:hasState ?s . ?s ?p ?o }"
    query_string = "SELECT ?s ?p ?o ?e WHERE { { #{parts.join(" UNION\n")} }}"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    raise Errors::NotFoundError.new("Failed to find #{uri} in #{self.name}.") if query_results.empty?
    item = from_results_recurse(uri, query_results.by_subject)
    ns_uri = item.has_identifier.has_scope
    item.has_identifier.has_scope = IsoNamespace.find(ns_uri)
    ra_uri = item.has_state.by_authority
    item.has_state.by_authority = IsoRegistrationAuthority.find(ra_uri)
    ns_uri = item.has_state.by_authority.ra_namespace
    item.has_state.by_authority.ra_namespace = IsoNamespace.find(ns_uri)
    item
  end

  # Where Full. Full where search of the managed item. Will find within children via paths that are not excluded.
  #
  # @return [Array] Array of URIs
  def where_full(params)
    where_parts = []
    params.each do |predicate, value|
      where_parts << "?s #{predicate} \"#{value}\""
    end
    where_clause = where_parts.join(" .\n")
    parts = []
    parts << "{ BIND (#{self.uri.to_ref} as ?s) . #{where_clause} }"
    self.class.read_paths.each {|p| parts << "{ #{self.uri.to_ref} (#{p})+ ?o1 . BIND (?o1 as ?s) . #{where_clause} }" }
    query_string = "SELECT DISTINCT ?s WHERE {{ #{parts.join(" UNION\n")} }}"
    query_results = Sparql::Query.new.query(query_string, uri.namespace, [])
    query_results.by_object(:s)
  end

  # Create. Creates a managed object.
  #
  # @params [Hash] params a set of initial vaues for any attributes
  # @return [Object] the created object. May contain errors if unsuccesful.
  def self.create(params)
    object = new(params)
    object.set_initial(params[:identifier])
    object.creation_date = object.last_change_date # Will have been set by set_initial, ensures the same one used.
    object.create_or_update(:create, true) if object.valid?(:create) && object.create_permitted?
    object
  end

  # History. Find the history for a given identifier within a scope
  #
  # @params [Hash] params
  # @params params [String] :identifier the identifier
  # @params params [IsoNamespace] :scope the scope namespace
  # @return [Array] An array of objects.
  def self.history(params)
    parts = []
    results = []
    base =  "?e isoT:hasIdentifier ?si . " +
            "?si isoI:identifier '#{params[:identifier]}' . " +
            "?si isoI:version ?v . " +
            "?si isoI:hasScope #{params[:scope].uri.to_ref} . "
    parts << "  { ?e ?p ?o . FILTER (strstarts(str(?p), \"http://www.assero.co.uk/ISO11179\")) BIND (?e as ?s) }"
    parts << "  { ?si ?p ?o . BIND (?si as ?s) }"
    parts << "  { ?e isoT:hasState ?s . ?s ?p ?o }"
    query_string = "SELECT ?s ?p ?o ?e WHERE { #{base} { #{parts.join(" UNION\n")} }} ORDER BY DESC (?v)"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    by_subject = query_results.by_subject
    query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri|
      item = from_results_recurse(uri, by_subject)
      set_cached_scopes(item, params[:scope])
      results << item
    end
    results
  end

  # History URIs. Find the history for a given identifier within a scope return just the URIs.
  #  Written for speed
  #
  # @params [Hash] params
  # @params params [String] :identifier the identifier
  # @params params [IsoNamespace] :scope the scope namespace
  # @return [Array] An array of objects.
  def self.history_uris(params)
    results = []
    base =  "?e rdf:type #{rdf_type.to_ref} . " +
            "?e isoT:hasIdentifier ?si . " +
            "?si isoI:identifier '#{params[:identifier]}' . " +
            "?si isoI:version ?v . " +
            "?si isoI:hasScope #{params[:scope].uri.to_ref} . "
    query_string = "SELECT ?e WHERE { #{base} } ORDER BY DESC (?v)"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT])
    query_results.by_object_set([:e]).each{|x| results << x[:e]}
    results
  end

  # History Previous
  #
  # @return [Uri] uri of the previous item in the history or nil if not found
  def history_previous
    history_previous_next(-1)
  end

  # History Next
  #
  # @return [Uri] uri of the next item in the history or nil if not found
  def history_next
    history_previous_next(1)
  end

  # History Pagination. Find the history for a given identifier within a scope by page
  #
  # @params [Hash] params
  # @params params [String] :identifier the identifier
  # @params params [IsoNamespace] :scope the scope namespace
  # @params params [String] :ofset the required offset
  # @params params [String] :count the number of items required
  # @return [Array] An array of URIs
  def self.history_pagination(params)
    parts = []
    results = []
    count = params[:count].to_i
    offset = params[:offset].to_i
    uris = history_uris(params)
    reqd_uris = uris[offset .. (offset + count - 1)]
    query_string = %Q{
      SELECT ?s ?p ?o ?e ?v WHERE {
        VALUES ?e { #{reqd_uris.map{|x| x.to_ref}.join(" ")} }
        {
          ?e isoT:hasIdentifier ?si .
          ?si isoI:version ?v .
          { ?e ?p ?o . FILTER (strstarts(str(?p), "http://www.assero.co.uk/ISO11179")) BIND (?e as ?s) } UNION
          { ?si ?p ?o . BIND (?si as ?s) } UNION
          { ?e isoT:hasState ?s . ?s ?p ?o }
        }
      } ORDER BY DESC (?v)
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    by_subject = query_results.by_subject
    query_results.subject_map.values.uniq{|x| x.to_s}.each do |uri|
      item = from_results_recurse(uri, by_subject)
      set_cached_scopes(item, params[:scope])
      results << item
    end
    results
  end

  # Comments. Return comments for all items with given identifier and scope
  #
  # @params [Hash] params
  # @params params [String] :identifier the identifier
  # @params params [IsoNamespace] :scope the scope namespace
  # @return [Array] An array of hash with the comment info.
  def self.comments(params)
    parts = []
    results = []
    base =  "?e isoT:hasIdentifier ?si . \n" +
            "?si isoI:identifier '#{params[:identifier]}' . \n" +
            "?si isoI:hasScope #{params[:scope].uri.to_ref} . \n" +
            "?si isoI:version ?v . \n" +
            "?si isoI:semanticVersion ?sv . \n" +
            "?e isoT:explanatoryComment ?ec . \n" +
            "?e isoT:changeDescription ?cdesc . \n" +
            "?e isoT:origin ?o . \n" +
            "?e isoT:creationDate ?cd . \n" +
            "?e isoT:lastChangeDate ?lcd . \n"
    query_string = "SELECT ?e ?sv ?ec ?cdesc ?o ?cd ?lcd ?v WHERE { #{base} } ORDER BY (?v)"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    query_results.by_object_set([:e, :sv, :ec, :cdesc, :o, :cd, :lcd]).each do |x|
      results << {uri: x[:e], version: x[:v], semantic_version: x[:sv], explanatory_comment: x[:ec], change_description: x[:cdesc],
                  origin: x[:o], last_change_date: x[:lcd].format_as_date, creation_date: x[:cd].format_as_date}
    end
    results
  end

  # Managed Children Pagination. Get managed children by page
  #
  # @params [Hash] params a hash of parameters
  # @params params [String] :offset the start offset of items to be returned
  # @params params [String] :count the count of items to be returned
  # @return [Array] array of objects
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
  # @return [Array] array of objects
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

  # Latest. Find the latest item from the history
  #
  # @params [Hash] params
  # @params params [String] :identifier the identifier
  # @params params [IsoNamespace] :scope the scope namespace
  # @return [IsoManaged] the found object or nil (if empty history)
  def self.latest(params)
    results = history_uris(params)
    results.empty? ? nil : find_minimum(results.first)
  end

  # Find the set of unique identifiers for a given RDF Type
  #
  # @return [Array] Each hash contains {identifier, scope_id, owner_short_name}
  def self.unique
    results = []
    check = {}
    query_string = %Q{
      SELECT DISTINCT ?e ?l ?i ?ns ?sn WHERE
      {
        ?e rdf:type #{rdf_type.to_ref} .
        ?e isoC:label ?l .
        ?e isoT:hasIdentifier ?si .
        ?si isoI:identifier ?i .
        ?si isoI:hasScope ?ns .
        ?ns isoI:shortName ?sn .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :isoR])
    triples = query_results.by_object_set([:e, :i, :l, :ns, :sn])
    triples.each do |entry|
      key = "#{entry[:sn]}.#{entry[:i]}"
      next if check.key?(key)
      results << {identifier: entry[:i], label: entry[:l], scope_id: entry[:ns].to_id, owner: entry[:sn]}
      check[key] = true
    end
    results
  end

  # Outputs change notes (also direct childrens') as CSV
  #
  # @return [CSV] the resulting csv data. Fail is there are errors.
  def change_notes_csv
    headers = ["Identifier", "Submission Value", "Label", "User Reference", "Timestamp", "Note Reference", "Note Description"]
    data = self.change_notes_paginated(offset: 0, count: 10000).map{|x| x.values}
    CSVHelpers.format(headers, data)
  end

  # Create Next Version. Creates the next version of the managed object if necessary
  #
  # @return [Object] the resulting object. Fail is there are errors.
  def create_next_version
    return self if !self.new_version? || self.has_state.multiple_edit
    ra = IsoRegistrationAuthority.owner
    sv = in_released_state? ? self.next_semantic_version.to_s : self.semantic_version
    object = self.clone
    object.has_identifier = IsoScopedIdentifierV2.from_h(identifier: self.scoped_identifier, version: self.next_version, semantic_version: sv, has_scope: ra.ra_namespace)
    object.has_state = IsoRegistrationStateV2.from_h(by_authority: ra, registration_status: self.state_on_edit, previous_state: self.registration_status)
    object.creation_date = Time.now
    object.last_change_date = Time.now
    object.set_uris(ra)
    object.create_or_update(:create, true) if object.valid?(:create) && object.create_permitted?
    object
  end

  # Delete. Delete the managed item
  #
  # @return [integer] the number of objects deleted (always 1 if no exception)
  def delete
      parts = []
      parts << "{ BIND (#{uri.to_ref} as ?s) . ?s ?p ?o }"
      self.class.delete_paths.each {|p| parts << "{ #{uri.to_ref} (#{p})+ ?o1 . BIND (?o1 as ?s) . ?s ?p ?o }" }
      query_string = "DELETE { ?s ?p ?o } WHERE {{ #{parts.join(" UNION\n")} }}"
      results = Sparql::Update.new.sparql_update(query_string, uri.namespace, [])
      1
  end

  # Delete minimum. Delete the managed item (Scope identifier, Registration State)
  #
  # @return [integer] the number of objects deleted (always 1 if no exception)
  def delete_minimum
    parts = []
    parts << "{ BIND (#{uri.to_ref} as ?s) . ?s ?p ?o }"
    parts << "{ #{uri.to_ref} isoT:hasIdentifier ?s . ?s ?p ?o}"
    parts << "{ #{uri.to_ref} isoT:hasState ?s . ?s ?p ?o }"
    query_string = "DELETE { ?s ?p ?o } WHERE {{ #{parts.join(" UNION\n")} }}"
    results = Sparql::Update.new.sparql_update(query_string, uri.namespace, [:isoT])
    1
  end

  # Forward Backward. Provides URIs for mving through the history
  #
  # @params [Integer] step the step to be taken, probably best set to 1
  # @params [Integer] window the window size; the number being displayed
  # @return [Hash] a hash containing six objects, start & end, forward & back by step, forward and back by window
  def forward_backward(step, window)
    result = {start: nil, backward_single: nil, backward_multiple: nil, forward_single: nil, forward_multiple: nil, end: nil}
    history_result = self.class.history_uris(scope: self.scope, identifier: self.scoped_identifier).reverse
    return result if history_result.empty?
    start_stop = 0
    end_stop = history_result.count - window
    my_index = history_result.index {|x| x == self.uri}
    result[:start] = history_result[start_stop] if my_index > start_stop
    result[:backward_single] = history_result[backward(my_index, step, start_stop)] if my_index > start_stop
    result[:backward_multiple] = history_result[backward(my_index, window, start_stop)] if my_index > start_stop
    result[:forward_single] = history_result[forward(my_index, step, end_stop)] if my_index < end_stop
    result[:forward_multiple] = history_result[forward(my_index, window, end_stop)] if my_index < end_stop
    result[:end] = history_result[end_stop] if my_index < end_stop
    result
  end

  # Determines if the item can be created
  #
  # @param ra [object] The Registration Authority
  # @return [boolean] True if create is permitted, false otherwise.
  def create_permitted?
    exists = IsoScopedIdentifierV2.exists?(self.scoped_identifier, self.scope)
    return true if self.version == IsoScopedIdentifierV2.first_version && !exists
    latest_version = IsoScopedIdentifierV2.latest_version(self.scoped_identifier, self.scope)
    return true if self.version > latest_version && exists
    if exists
      self.errors.add(:base, "The item cannot be created. The identifier is already in use.")
    else
      self.errors.add(:base, "The item cannot be created. Identifier does not exist but version [#{self.version}] error.")
    end
    false
  end

  # Update Comments
  #
  # @params [Hash] The parameters {:explanatoryComment, :changeDescription, :origin}
  # @raise [Exceptions::UpdateError] if an error occurs during the update
  # @return null
  def update_comments(params)
    partial_update(update_query(params), [:isoT])
  end

  # Update Status. Update the status.
  #
  # @params [Hash] params the parameters
  # @option params [String] Registration Status, the new state
  # @return [Null] errors are in the error object, if any
  def update_status(params)
    params[:multiple_edit] = false  
    self.has_state.update(params)
    return if merge_errors(self.has_state, "Registration Status")
    sv = SemanticVersion.from_s(self.semantic_version)
    self.has_identifier.update(semantic_version: sv.to_s) if self.has_state.released_state?
    merge_errors(self.has_identifier, "Scoped Identifier")
  end

  # Set URIs. Sets the URIs for the managed item and all children
  #
  # @param [IsoRegistrationAuthority] ra the registration authority under which the item is being registered
  # @return [Void] no return
  def set_uris(ra)
    generate_uri(Uri.new(authority: ra.ra_namespace.authority, identifier: self.scoped_identifier, version: self.version))
  end

  # Set Intial. Sets the SI and RS fields to the initial values for a new item.
  #
  # @param [String] indentifier the identifier
  # @return [Void] no return
  def set_initial(identifier)
    ra = IsoRegistrationAuthority.owner
    self.has_identifier = IsoScopedIdentifierV2.from_h(identifier: identifier, version: 1, semantic_version: SemanticVersion.first.to_s, has_scope: ra.ra_namespace)
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
      semantic_version: params[:semantic_version], has_scope: ra.ra_namespace)
    self.has_state = IsoRegistrationStateV2.from_h(by_authority: ra, registration_status: IsoRegistrationStateV2.released_state,
      previous_state: IsoRegistrationStateV2.released_state)
    self.creation_date = params[:date].to_time_with_default
    self.last_change_date = params[:date].to_time_with_default
    set_uris(ra)
  end

  # Update Identifier. Updates the identifier. Resets the URIs but no save.
  #
  # @param [String] identifier the new identifier
  # @return [Void] no return
  def update_identifier(identifier)
    self.has_identifier.identifier = identifier
    set_uris(self.has_state.by_authority)
  end

  # Update Version. Updates the version including the semantic version. Resets the URIs but no save.
  #
  # @param [Integer] version the new version
  # @return [Void] no return
  def update_version(version)
    self.has_identifier.version = version
    self.has_identifier.semantic_version = SemanticVersion.from_s("#{version}.0.0").to_s
    set_uris(self.has_state.by_authority)
  end

  # Next Ordinal. Get the next ordinal for a managed item collection
  #
  # @param [String] name the name of the property holding the collection
  # @return [Integer] the next ordinal
  def next_ordinal(name)
    predicate = self.properties.property(name).predicate
    query_string = %Q{
      SELECT (MAX(?ordinal) AS ?max)
      {
        #{self.uri.to_ref} #{predicate.to_ref} ?s .
        ?s bo:ordinal ?ordinal
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:bo])
    return 1 if query_results.empty?
    query_results.by_object(:max).first.to_i + 1
  end

  # Current Set. Find the set of current items for the class
  #
  # @return [Array] array of Uri objects
  def self.current_set
    date_time = Time.now.iso8601
    query_string = %Q{
      SELECT ?a WHERE
      {
        ?a rdf:type #{rdf_type.to_ref} .
        ?a isoT:hasState ?c .
        ?c isoR:effectiveDate ?d .
        ?c isoR:untilDate ?e .
        FILTER ( xsd:dateTime(?d) <= \"#{date_time}\"^^xsd:dateTime ) .
        FILTER ( xsd:dateTime(?e) >= \"#{date_time}\"^^xsd:dateTime ) .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoT, :isoR])
    query_results.by_object(:a)
  end

  # Current And Latest Set. Find the current and latest versions for all identifiers for a given type.
  #
  # @return [Array] Each hash contains {uri}
  def self.current_and_latest_set
    results = Hash.new {|h,k| h[k] = []}
    date_time = Time.now.iso8601
    query_string = %Q{
      SELECT DISTINCT ?s ?key ?v WHERE
      {
        {
          SELECT DISTINCT ?s ?key ?v WHERE
          {
            ?s rdf:type #{rdf_type.to_ref} .
            ?s isoT:hasIdentifier ?si .
            ?s isoT:hasState ?st .
            ?st isoR:effectiveDate ?ed .
            ?st isoR:untilDate ?ud .
            FILTER ( xsd:dateTime(?ed) <= \"#{date_time}\"^^xsd:dateTime ) .
            FILTER ( xsd:dateTime(?ud) >= \"#{date_time}\"^^xsd:dateTime ) .
            ?si isoI:version ?v .
            ?si isoI:identifier ?i .
            ?si isoI:hasScope ?ns .
            ?ns isoI:shortName ?sn .
            BIND(CONCAT(STR(?sn),".",STR(?i)) AS ?key)
          }
        } UNION {
          SELECT DISTINCT ?s ?key ?v WHERE
          {
            ?s rdf:type #{rdf_type.to_ref} .
            ?s isoT:hasIdentifier ?si .
            {
              SELECT (max(?lv) AS ?v) WHERE
              {
                ?s rdf:type <http://www.assero.co.uk/Thesaurus#Thesaurus> .
                ?s isoT:hasIdentifier/isoI:version ?lv .
              }
            }
            ?si isoI:version ?v .
            ?si isoI:identifier ?i .
            ?si isoI:hasScope ?ns .
            ?ns isoI:shortName ?sn .
            BIND(CONCAT(STR(?sn),".",STR(?i)) AS ?key)
          }
        }
      } ORDER BY ?key DESC(?v)
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoC, :isoR])
    query_results.by_object_set([:s, :key, :v]).map{|x| results[x[:key]]<<{uri: x[:s], version: x[:v].to_i}}
    results
  end

  # Current And Latest Parent. Find the latest or the current parent
  #
  # @return [Array] An array of objects.
  def current_and_latest_parent
    date_time = Time.now.iso8601
    query_string = %Q{
      SELECT ?s ?v WHERE
      {
        {
          #{self.uri.to_ref} ^bo:reference ?or .
          ?s ?p ?or .
          ?s isoT:hasState ?st .
          ?st isoR:effectiveDate ?ed .
          ?st isoR:untilDate ?ud .
          FILTER ( xsd:dateTime(?ed) <= \"#{date_time}\"^^xsd:dateTime ) .
          FILTER ( xsd:dateTime(?ud) >= \"#{date_time}\"^^xsd:dateTime )
          ?s isoT:hasIdentifier ?si .
          ?si isoI:version ?v .
        } UNION {
          #{self.uri.to_ref} ^bo:reference ?or .
          ?s ?p ?or .
          ?s isoT:hasIdentifier ?si .
          ?si isoI:version ?v .
          {
            SELECT (max(?lv) AS ?v) WHERE
            {
              #{self.uri.to_ref} ^bo:reference ?or .
              ?x ?p ?or .
              ?x isoT:hasIdentifier/isoI:version ?lv .
            } GROUP BY ?s
          }
        }
      } ORDER BY DESC (?v)
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoR, :bo])
    results = query_results.by_object_set([:s, :v])
    raise Errors::NotFoundError.new("Failed to find best parent for #{self.uri}.") if results.empty?
    results.map{|x| {uri: x[:s], version: x[:v].to_i}}
  end

  # Current. Find the current item for the scope.
  #
  # @params [Hash] params
  # @params params [String] :identifier the identifier
  # @params params [IsoNamespace] :scope the scope namespace
  # @raise [Errors::ApplicationLogicError] raised if mutliple items found
  # @return [object] the current item if found, nil otherwise
  def self.current(params)
    date_time = Time.now.iso8601
    query_string = %Q{
      SELECT ?s WHERE
      {
        ?s rdf:type #{rdf_type.to_ref} .
        ?s isoT:hasIdentifier ?si .
        ?s isoT:hasState ?rs .
        ?si isoI:identifier '#{params[:identifier]}' .
        ?si isoI:hasScope #{params[:scope].uri.to_ref} .
        ?rs isoR:effectiveDate ?d .
        ?rs isoR:untilDate ?e .
        FILTER ( xsd:dateTime(?d) <= \"#{date_time}\"^^xsd:dateTime ) .
        FILTER ( xsd:dateTime(?e) >= \"#{date_time}\"^^xsd:dateTime ) .
      }
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoT, :isoR, :isoI])
    return nil if query_results.empty?
    results = query_results.by_object(:s)
    Errors.application_error(self.class.name, __method__.to_s, "Multiple current items found for identifier '#{params[:identifier]}' within scope '#{params[:scope].uri}'.") if results.count > 1
    results.first
  end

  # Find By Tag. Find all managed items based on a tag.
  #
  # @param id [String] the id of the tag
  # @return [Array] Array of hash
  def self.find_by_tag(id)
    results = []
    uri = Uri.new(id: id)
    query_string = %Q{
SELECT ?s ?l ?v ?i ?vl WHERE {
  #{uri.to_ref} ^isoC:tagged ?s .
  ?s isoC:label ?l .
  ?s isoT:hasIdentifier/isoI:version ?v .
  ?s isoT:hasIdentifier/isoI:semanticVersion ?sv .
  ?s isoT:hasIdentifier/isoI:identifier ?i .
  ?s isoT:hasIdentifier/isoI:versionLabel ?vl
} ORDER BY DESC(?v) OFFSET 0 LIMIT 1000}
    query_results = Sparql::Query.new.query(query_string, "", [:isoC, :isoI, :isoT])
    query_results.by_object_set([:s, :i, :v, :sv, :l, :vl]).each do |x|
      results << {uri: x[:s].to_s, id: x[:s].to_id, identifier: x[:i], version: x[:v], semantic_version: x[:sv], label: x[:l], version_label: x[:vl]}
    end
    results
  end

  # Make Current. Make the item current
  #
  # @return [Boolean] always returns true.
  def make_current
    transaction_begin
    clear_current
    self.has_state.make_current
    transaction_execute
    true
  end

private

  # Clear Current, if any
  def clear_current
    current_uri = self.class.current(identifier: self.scoped_identifier, scope: self.scope)
    return false if current_uri.nil?
    current_item = IsoManagedV2.find_minimum(current_uri)
    current_item.has_state.make_not_current
    true
  end

  # In released state
  def in_released_state?
    self.has_state.registration_status == IsoRegistrationStateV2.released_state
  end

  # History previous / next
  def history_previous_next(step)
    results = []
    base =  "?e rdf:type #{rdf_type.to_ref} . " +
            "?e isoT:hasIdentifier ?si . " +
            "?si isoI:identifier '#{self.scoped_identifier}' . " +
            "?si isoI:version  #{self.version + step}. " +
            "?si isoI:hasScope #{self.scope.uri.to_ref} . "
    query_string = "SELECT ?e WHERE { #{base} }"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT])
    return nil if query_results.empty?
    return self.class.find_minimum(query_results.by_object_set([:e]).first[:e])
  end

  # Set the scopes, will use the cache so quick.
  def self.set_cached_scopes(object, si_scope)
    object.has_identifier.has_scope = si_scope
    object.has_state.by_authority = IsoRegistrationAuthority.find(object.has_state.by_authority)
    object.has_state.by_authority.ra_namespace = IsoNamespace.find(object.has_state.by_authority.ra_namespace)
  end

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

  # Mini history with state and semantic version
  def state_and_semantic_version(params)
    results = []
    query_string = %Q{
      SELECT ?s ?sv ?st WHERE
        {
          ?s rdf:type #{self.rdf_type.to_ref} .
          ?s isoT:hasIdentifier ?si .
          ?si isoI:identifier "#{params[:identifier]}" .
          ?si isoI:version ?v .
          ?si isoI:semanticVersion ?sv .
          ?si isoI:hasScope #{params[:scope].uri.to_ref} .
          ?s isoT:hasState/isoR:registrationStatus ?st
        } ORDER BY DESC (?v)
    }
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoT, :isoR])
    query_results.by_object_set([:s, :sv, :st]).each do |x|
      results << {uri: x[:s], semantic_version: x[:sv], state: x[:st]}
    end
    results
  end

  # The update previous release query
  def update_previous_releases(params)
    uris = params[:uris].map{|x| x.to_ref}.join(" ")
    query_string= %Q{
      DELETE
      {
        ?s ?p ?o
      }
      INSERT
      {
       ?s ?p \"#{params[:semantic_version]}\"^^xsd:string .
      }
      WHERE
      {
        VALUES ?x {#{uris}}
        ?x isoT:hasIdentifier ?s .
        ?s isoI:semanticVersion ?o .
        BIND (isoI:semanticVersion as ?p)
      }
    }
    partial_update(query_string, [:isoI, :isoT])
  end

  def uris
    uris = {uris: []}
    results = state_and_semantic_version(identifier: self.has_identifier.identifier, scope: self.scope)
    raise Errors::NotFoundError.new("Failed to find previous semantic versions for #{self.uri}.") if results.empty?
    item_index = results.index {|x| x[:state] == IsoRegistrationStateV2.released_state}
    item_index.nil? ? results[0..-2].each{|hash| uris[:uris].push(hash[:uri]) } : results[0..item_index-1].each{|hash| uris[:uris].push(hash[:uri]) }
    uris
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

end
