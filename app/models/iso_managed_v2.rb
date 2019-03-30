# ISO Managed (V2) 
#
# @author Dave Iberson-Hurst
# @since 2.21.1
class IsoManagedV2 < IsoConceptV2

  extend Resource

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
    return self.has_state.registrationStatus
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
        # Initialise.
    query_string = "SELECT ?s ?p ?o WHERE \n" +
      "{ \n" +
      "  #{uri.to_ref} (:|!:)* ?s .\n" +
      "  ?s ?p ?o .\n" + 
      "  ?s rdf:type ?t .\n" + 
      "  FILTER (?t IN (#{subject_set(full)})) .\n" +
      "}"
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
    parts[0] = "  { ?e ?p ?o . BIND (?e as ?s) }" 
    parts[1] = "  { ?si ?p ?o . BIND (?si as ?s) }"  
    parts[2] = "  { #{params[:scope].uri.to_ref} ?p ?o . BIND (#{params[:scope].uri.to_ref} as ?s)}" 
    parts[3] = "  { ?e isoT:hasState ?s . ?s ?p ?o }" 
    query_string = "SELECT ?s ?p ?o ?e WHERE { #{base} { #{parts.join(" UNION\n")} }}"
    query_results = Sparql::Query.new.query(query_string, "", [:isoI, :isoR, :isoC, :isoT])
    query_results.subject_map.values.uniq{|x| x.to_s}.each {|uri| results << from_results_recurse(uri, query_results.by_subject)}
    results
  end


  # Update the item
  #
  # @params [Hash] The parameters {:explanatoryComment, :changeDescription, :origin}
  # @raise [Exceptions::UpdateError] if an error occurs during the update
  # @return null
  def update(params)  
    Sparql::Update.new.sparql_update(update_query(params), self.rdf_type.namespace, [:isoT])
  end
  
private

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
    set = 
    [
      IsoRegistrationStateV2.rdf_type.to_ref, IsoScopedIdentifierV2.rdf_type.to_ref, 
      IsoNamespace.rdf_type.to_ref, IsoRegistrationAuthority.rdf_type.to_ref, self.rdf_type.to_ref
    ]
    config = self.class.instance_variable_get(:@configuration)
    set = set + config[:relationships] if full && !config.nil?
    set.join(",")
  end

end