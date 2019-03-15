class IsoManaged < IsoConcept

  #include CRUD
  #include ModelUtility
  
  attr_accessor :registrationState, :scopedIdentifier, :origin, :changeDescription, :creationDate, :lastChangeDate, :explanatoryComment, :tag_refs, :branched_from_ref, :triples

  # Constants
  C_CID_PREFIX = "ISOM"
  C_CLASS_NAME = self.class.to_s
  C_SCHEMA_PREFIX = "isoC"
  C_INSTANCE_PREFIX = "mdrItems"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)

  #C_BCPV = "http://www.assero.co.uk/CDISCBiomedicalConcept#PropertyValue"
  #C_COMPONENT = "http://www.assero.co.uk/BusinessOperational/Component"

  # Initialize the object
  #
  # @param triples [hash] Hash containing multiple triples keyed by id
  # @param id [string] Teh id for the object being initialized
  # @return [object] The object, either initialized with triples or blank.
  def initialize(triples=nil, id=nil)
    self.origin = ""
    self.changeDescription = ""
    self.creationDate = Time.now
    self.lastChangeDate = Time.now
    self.explanatoryComment = ""
    self.registrationState = IsoRegistrationState.new
    self.scopedIdentifier = IsoScopedIdentifier.new
    self.tag_refs = Array.new
    self.branched_from_ref = nil
    self.triples = Hash.new
    if triples.nil?
      super
    else
      self.triples = triples
      super(triples, id)
      if self.link_exists?(UriManagement::C_ISO_T, "hasIdentifier")
        links = self.get_links_v2(UriManagement::C_ISO_T, "hasIdentifier")
        self.scopedIdentifier = IsoScopedIdentifier.new(triples[links[0].id])
        if self.link_exists?(UriManagement::C_ISO_T, "hasState")
          links = self.get_links_v2(UriManagement::C_ISO_T, "hasState")
          self.registrationState= IsoRegistrationState.new(triples[links[0].id])
        end
      end
      self.tag_refs = self.get_links_v2(UriManagement::C_ISO_C, "hasMember")  
      links = self.get_links_v2(UriManagement::C_BO, "branchedFrom")
      self.branched_from_ref = OperationalReferenceV2.find_from_triples(self.triples, links[0].id) if links.length > 0
    end    
  end  

  # Version
  #
  # @return [string] The version
  def version
    return self.scopedIdentifier.version
  end

  # Version Label
  #
  # @return [string] The version label
  def version_label
    return self.scopedIdentifier.versionLabel
  end

  # Version Label - Deprecated due to bad naming syntax
  #
  # @return [string] The version label
  alias versionLabel version_label
  
  # Semantic Version
  #
  # @return [SemanticVersion] The semantic version
  def semantic_version
    return self.scopedIdentifier.semantic_version
  end

  # Return the identifier
  #
  # @return [string] The identifier.
  def identifier
    return self.scopedIdentifier.identifier
  end

  # Latest version
  #
  # @return [boolean] Returns true of latest
  def latest?
    latest_version = IsoScopedIdentifier.latest(self.identifier, self.owner_id)
    return self.version == latest_version
  end

  # Later Version
  #
  # @return [boolean] Returns true if the item has a version later than that specified
  def later_version?(version)
    return self.scopedIdentifier.later_version?(version)
  end
  
  # Earlier Version
  #
  # @return [boolean] Returns true if the item has a version earlier than that specified
  def earlier_version?(version)
    return self.scopedIdentifier.earlier_version?(version)
  end
  
  # Same Version
  #
  # @return [boolean] Returns true if the item has the same version as that specified
  def same_version?(version)
    return self.scopedIdentifier.same_version?(version)
  end
  
  # Return the owner of the managed item
  #
  # @return [object] The owner namespace object.
  def owner
    return self.registrationState.registrationAuthority
  end

  # Return the owner id
  #
  # @return [String] The owner id.
  def owner_id
    return owner.uri.fragment
  end

  # Determine if the object is owned by this repository
  #
  # @return [boolean] True if owned, false otherwise
  def owned?
    respository_owner = IsoRegistrationAuthority.owner
    return self.owner.uri == respository_owner.uri
  end

  # Determine if the object is a branch, i.e. a child
  #
  # @return [boolean] True if owned, false otherwise
  def is_a_branch?
    return !self.branched_from_ref.nil?
  end

  # Determine if the item can be branched
  #
  # @return [Boolean] true iof the item can be branched, false otherwise
  def can_be_branched?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.released_state? || self.registrationState.has_been_released_state? 
    end
  end

  # Return the registration status
  #
  # @return [string] The status
  def registrationStatus
    if self.registrationState == nil
      return "na"
    else
      return self.registrationState.registrationStatus
    end
  end

  # Checks if item is regsitered
  #
  # @return [boolean] True if registered, false otherwise
  def registered?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.registered?
    end
  end

  # Determines if edit is allowed.
  #
  # @return [boolean] True if edit is permitted, false otherwise.
  def edit?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.edit? && self.owned?
    end
  end

  # Determines if the item can be deleted.
  #
  # @return [boolean] Ture if delete allowed, false otherwise.
  def delete?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.delete?
    end
  end

  # Determines if a new version can be created
  #
  # @return [boolean] True if can be created, false otherwise
  def new_version?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.new_version?
    end
  end

  # Get the state after an edit.
  #
  # @return [string] The state.
  def state_on_edit
    if self.registrationState == nil
      return IsoRegistrationState.no_state
    else
      return self.registrationState.state_on_edit
    end
  end

  # Checks if item can be the current item.
  #
  # @return [boolean] True if can be current, false otherwise. 
  def can_be_current?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.can_be_current?
    end
  end

  # Return the next version
  #
  # @return [integer] the next version
  def next_version
    self.scopedIdentifier.next_version
  end

  # Return the next version
  #
  # @return [integer] the next version
  def self.next_version(identifier, scope)
    IsoScopedIdentifier.next_version(identifier, scope)
  end

  # Return the next semantic version
  #
  # @return [SemanticVersion] the next semantic version
  def next_semantic_version
    self.scopedIdentifier.next_semantic_version
  end

  # Return the first version
  #
  # @return [string] The first version
  def first_version
    IsoScopedIdentifier.first_version
  end

  # Is the item the current item.
  #
  # @return [boolean] True if current, false otherwise
  def current?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.current
    end
  end

  # Does the item exist within the given authority namespace
  #
  # @return [boolean] True if exists, false otherwise.
   def exists?
    result = self.scopedIdentifier.exists?
  end

  # Does the version exist.
  #
  # @return [boolean] True if exists, false otherwise
  def version_exists?
    result = self.scopedIdentifier.version_exists?
  end

  # Find the type
  #
  # @return [hash] The JSON hash.
  def self.get_type(id, namespace)
    return super(id, namespace)
  end

  # Find
  #
  # @param id [string] the id of the item 
  # @param ns [string] the namespace of the item
  # @param full [boolean] All child triples if set true, otherwise just the ttop level concept
  # @return [object] The object.
  def self.find(id, ns, full=true)  
    # Initialise.
    object = nil
    # Create the query and action.
    query = UriManagement.buildNs(ns, [UriManagement::C_ISO_T]) +
      "SELECT ?s ?p ?o WHERE \n" +
      "{ \n" +
      "  { \n"
    if full
      query += 
      "    :" + id + " (:|!:)* ?s .\n" +
      "    ?s ?p ?o .\n" + 
      "    FILTER(STRSTARTS(STR(?s), \"" + ns + "\"))  \n" 
    else
      query += 
      "    BIND ( :" + id + " as ?s ) .\n" +
      "    ?s ?p ?o .\n" 
    end
    query +=  
      "  } UNION {\n" +
      "    :" + id + " isoT:hasIdentifier ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  } UNION {\n" +
      "    :" + id + " isoT:hasState ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  }\n" +
      "}"
    response = CRUD.query(query)
    # Process the response.
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      subject = ModelUtility.getValue('s', true, node)
      predicate = ModelUtility.getValue('p', true, node)
      objectUri = ModelUtility.getValue('o', true, node)
      objectLiteral = ModelUtility.getValue('o', false, node)
      #ConsoleLogger::log(C_CLASS_NAME,"find","p=(#{subject},#{predicate},#{objectUri}#{objectLiteral})")
      if predicate != ""
        triple_object = objectUri
        if triple_object == ""
          triple_object = objectLiteral
        end
        key = ModelUtility.extractCid(subject)
        triples[key] << {:subject => subject, :predicate => predicate, :object => triple_object}
      end
    end
    # Create the object based on the triples.
    object = new(triples, id)
    raise Exceptions::NotFoundError.new(message: "Failed to find #{ns}##{id} in #{C_CLASS_NAME} object.") if object.id.empty?
    return object   
  end

  # Find list of managed items of a given type.
  #
  # @rdfType [string] The RDF type
  # @ns [string] The namespace
  # @return [array] Array of objects found.
  def self.unique(rdfType, ns)
    results = IsoScopedIdentifier.allIdentifier(rdfType, ns)
  end

  # Find all managed items based on their type.
  #
  # @rdfType [string] The RDF type
  # @ns [string] The namespace
  # @return [array] Array of objects found.
  def self.all_by_type(rdfType, ns)
    results = Array.new
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h ?i WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?i . \n" +
      "  OPTIONAL { \n" +
      "    ?a isoT:hasIdentifier ?h . \n" +
      "    OPTIONAL { \n" +
      "      ?a isoT:hasState ?b . \n" +
      "      ?a isoT:origin ?c . \n" +
      "      ?a isoT:changeDescription ?d . \n" +
      "      ?a isoT:creationDate ?e . \n" +
      "      ?a isoT:lastChangeDate  ?f . \n" +
      "      ?a isoT:explanatoryComment ?g . \n" +
      "    } \n" +
      "  } \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      iiSet = node.xpath("binding[@name='h']/uri")
      rsSet = node.xpath("binding[@name='b']/uri")
      oSet = node.xpath("binding[@name='c']/literal")
      descSet = node.xpath("binding[@name='d']/literal")
      dateSet = node.xpath("binding[@name='e']/literal")
      lastSet = node.xpath("binding[@name='f']/literal")
      commentSet = node.xpath("binding[@name='g']/literal")
      label = ModelUtility.getValue('i', false, node)
      if uri != "" 
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdf_type = rdfType
        object.label = label
        if iiSet.length == 1
          object.scopedIdentifier = IsoScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
          if rsSet.length == 1
            object.registrationState = IsoRegistrationState.find(ModelUtility.extractCid(rsSet[0].text))
            object.origin = oSet[0].text
            object.changeDescription = descSet[0].text
            object.creationDate = dateSet[0].text.to_time_with_default
            object.lastChangeDate = lastSet[0].text.to_time_with_default
            object.explanatoryComment = commentSet[0].text
          else
            object.registrationState = nil
            object.origin = ""
            object.changeDescription = ""
            object.creationDate = Time.now
            object.lastChangeDate = Time.now
            object.explanatoryComment = ""
          end
        else
          object.scopedIdentifier = nil
        end
        results << object
      end
    end
    return results
  end

  # Find all managed items.
  #
  # @return [array] Array of objects found.
  def self.all
    results = Array.new
    # Create the query
    query = UriManagement.buildNs("", ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?l ?i ?sv ?s ?ra WHERE \n" +
      "{ \n" +
      "  ?a rdfs:label ?l . \n" +
      "  ?a isoT:hasIdentifier ?si . \n" +
      "  ?a isoT:hasState ?rs . \n" +
      "  ?si isoI:identifier ?i . \n" +
      "  ?si isoI:semanticVersion ?sv . \n" +
      "  ?rs isoR:registrationStatus ?s . \n" +
      "  ?rs isoR:byAuthority ?ra . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      if uri != ""
      	label = ModelUtility.getValue('l', false, node)
  	    identifier = ModelUtility.getValue('i', false, node)
    	  semantic_version = ModelUtility.getValue('sv', false, node)
      	status = ModelUtility.getValue('s', false, node)
        ra_uri = Uri.new({uri: ModelUtility.getValue('ra', true, node)})
        ra = IsoRegistrationAuthority.find_children(ra_uri)
        object_uri = UriV2.new({:uri => uri})
        results << 
        	{ id: object_uri.id, 
        		namespace: object_uri.namespace, 
        		label: label, 
        		identifier: identifier, 
        		semantic_version: semantic_version, 
        		status: status, 
        		owner: ra.ra_namespace.short_name 
        	}
      end
    end
    return results
  end

  # Find all managed items based on tag settings.
  # Return the object as JSON
  #
  # @param id [string] the id of the item 
  # @param namespace [string] the namespace of the item
  # @return [hash] The JSON hash.
  def self.find_by_tag(id, namespace)
    results = Array.new
    # Create the query
    uri = UriV2.new({:id => id, :namespace => namespace})
    query = UriManagement.buildNs(namespace, ["isoT", "isoC"]) +
      "SELECT ?a ?b ?c ?d ?e WHERE \n" +
      "{ \n" +
      "  ?a rdfs:label ?b . \n" +
      "  ?a isoC:hasMember #{uri.to_ref} . \n" +
      "  ?a isoT:hasIdentifier ?d . \n" +
      "  ?a rdf:type ?e . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      si = ModelUtility.getValue('d', true, node)
      label = ModelUtility.getValue('b', false, node)
      rdf_type = ModelUtility.getValue('e', true, node)
      if uri != "" 
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdf_type = rdf_type
        object.label = label
        object.scopedIdentifier = IsoScopedIdentifier.find(ModelUtility.extractCid(si))
        results << object
      end
    end
    return results
  end

  # Find By Property. Find all managed items based on property
  #
  # @param [Hash] params a parameters hash
  # @option params [String] :text the text to be used for the search
  # @return [Array] the results in an array of hashes.
  def self.find_by_property(params)
    results = Array.new
    query = UriManagement.buildNs("", ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?b ?c ?si ?rs ?d ?e ?f ?g ?h WHERE \n" +
      "{ \n" +
      "  ?a rdfs:label ?b . \n" +
      "  ?a isoT:hasIdentifier ?si . \n" +
      "  ?si isoI:identifier ?e . \n" +
      "  FILTER (regex(?b, '#{params[:text]}') || regex(?e, '#{params[:text]}')) . \n" +
      "  ?a rdf:type ?h . \n" +
      "  ?a isoT:creationDate ?c . \n" +
      "  ?a isoT:lastChangeDate  ?d . \n" +
      "  ?a isoT:hasState ?rs . \n" +
      "  ?si isoI:version ?f . \n" +
      "  ?rs isoR:registrationStatus ?g . \n" +
      "} ORDER BY DESC(?f)"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      si = ModelUtility.getValue('si', true, node)
      rs = ModelUtility.getValue('rs', true, node)
      label = ModelUtility.getValue('b', false, node)
      dateSet = ModelUtility.getValue('c', false, node)
      lastSet = ModelUtility.getValue('d', false, node)
      identifier = ModelUtility.getValue('e', false, node)
      version = ModelUtility.getValue('f', false, node)
      status = ModelUtility.getValue('g', false, node)
      rdf_type = ModelUtility.getValue('h', true, node)
      object = self.new
      object.id = ModelUtility.extractCid(uri)
      object.namespace = ModelUtility.extractNs(uri)
      object.rdf_type = rdf_type
      object.label = label
      object.creationDate = dateSet.to_time_with_default
      object.lastChangeDate = lastSet.to_time_with_default
      si_uri = UriV2.new({:uri => si})
      rs_uri = UriV2.new({:uri => rs})
      object.scopedIdentifier = IsoScopedIdentifier.find(si_uri.id)
      object.registrationState = IsoRegistrationState.find(rs_uri.id)
      results << object
    end
    return results  
  end

  # Find history for a given identifier
  #
  # @rdfType [String] The RDF type
  # @ns [String] The namespace
  # @param params [Hash] the options
  # @option params [String] :identifier the scoped identifier
  # @option params [Uri] :scope the scope
  # @return [Array] An array of objects.
  def self.history(rdfType, ns, params)    
    identifier = params[:identifier]
    type_uri = UriV2.new({:id => rdfType, :namespace => ns})
    results = Array.new
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR", "mdrItems"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h ?i ?j WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType.to_s + " . \n" +
      "  ?a rdfs:label ?i . \n" +
      "  ?a isoT:hasIdentifier ?h . \n" +
      "  ?h isoI:identifier \"" + identifier.to_s + "\" . \n" +
      "  ?h isoI:hasScope #{params[:scope].uri.to_ref} . \n" +
      "  ?h isoI:version ?j . \n" +
      "  OPTIONAL { \n" +
      "    ?a isoT:hasState ?b . \n" +
      "    ?a isoT:origin ?c . \n" +
      "    ?a isoT:changeDescription ?d . \n" +
      "    ?a isoT:creationDate ?e . \n" +
      "    ?a isoT:lastChangeDate  ?f . \n" +
      "    ?a isoT:explanatoryComment ?g . \n" +
      "  } \n" +
      "} ORDER BY DESC(?j)"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      iiSet = node.xpath("binding[@name='h']/uri")
      rsSet = node.xpath("binding[@name='b']/uri")
      oSet = node.xpath("binding[@name='c']/literal")
      descSet = node.xpath("binding[@name='d']/literal")
      dateSet = node.xpath("binding[@name='e']/literal")
      lastSet = node.xpath("binding[@name='f']/literal")
      commentSet = node.xpath("binding[@name='g']/literal")
      label = ModelUtility.getValue('i', false, node)
      version = ModelUtility.getValue('j', false, node)
      if uri != "" 
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdf_type = type_uri.to_s
        object.label = label
        object.origin = oSet[0].text
        object.changeDescription = descSet[0].text
        object.creationDate = dateSet[0].text.to_time_with_default
        object.lastChangeDate = lastSet[0].text.to_time_with_default
        object.explanatoryComment = commentSet[0].text
        if iiSet.length == 1
          # Set scoped identifier
          object.scopedIdentifier = IsoScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
          # Registration state?
          if rsSet.length == 1
            object.registrationState = IsoRegistrationState.find(ModelUtility.extractCid(rsSet[0].text))           
          end
        end
        results << object
      end
    end
    return results  
  end

  def self.changes(klass, params, options={})
    items = []
    klass.history(params).each { |i| items << klass.find(i.id, i.namespace)}
    result = IsoConcept.changes(items, params[:child_property], options)
    result[:versions] = []
    result[:changes].each { |r| result[:versions] << r[:scoped_identifier][:semantic_version] }
    return result
  end

  # Find all released item for all identifiers of a given type.
  #
  # @rdfType [string] The RDF type
  # @ns [string] The namespace
  # @return [array] An array of objects.
  def self.list(rdf_type, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"list","*****Entry*****")    
    results = Array.new
    type_uri = UriV2.new({:id => rdf_type, :namespace => ns})
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?b ?c ?si ?rs ?d ?e ?f ?g ?h WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdf_type + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  ?a isoT:creationDate ?c . \n" +
      "  ?a isoT:lastChangeDate  ?d . \n" +
      "  ?a isoT:hasIdentifier ?si . \n" +
      "  ?a isoT:hasState ?rs . \n" +
      "  ?si isoI:identifier ?e . \n" +
      "  ?si isoI:version ?f . \n" +
      "  ?rs isoR:registrationStatus ?g . \n" +
      "} ORDER BY DESC(?f)"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      si = ModelUtility.getValue('si', true, node)
      rs = ModelUtility.getValue('rs', true, node)
      label = ModelUtility.getValue('b', false, node)
      dateSet = ModelUtility.getValue('c', false, node)
      lastSet = ModelUtility.getValue('d', false, node)
      identifier = ModelUtility.getValue('e', false, node)
      version = ModelUtility.getValue('f', false, node)
      status = ModelUtility.getValue('g', false, node)
      #scope = ModelUtility.getValue('h', true, node)
      #ConsoleLogger::log(C_CLASS_NAME,"list","node=" + node.to_s)
      if uri != "" 
        if status == IsoRegistrationState.releasedState
          object = self.new
          object.id = ModelUtility.extractCid(uri)
          object.namespace = ModelUtility.extractNs(uri)
          object.rdf_type = type_uri.to_s
          object.label = label
          object.creationDate = dateSet.to_time_with_default
          object.lastChangeDate = lastSet.to_time_with_default
          si_uri = UriV2.new({:uri => si})
          rs_uri = UriV2.new({:uri => rs})
          object.scopedIdentifier = IsoScopedIdentifier.find(si_uri.id)
          object.registrationState = IsoRegistrationState.find(rs_uri.id)
          results << object
        end
      end
    end
    return results  
  end

  # Find the current item
  #
  # @param rdf_type [string] RDF type
  # @param namespace [string] The schema namespace
  # @param params [Hash] the options
  # @option params [String] :identifier the scoped identifier
  # @option params [Uri] :scope the scope
  # @return [object] The object or nil if no current version.
  def self.current(rdf_type, namespace, params)    
    identifier = params[:identifier]
    date_time = Time.now.iso8601.gsub('+',"%2B")
    results = Array.new
    # Create the query
    query = UriManagement.buildNs(namespace, ["isoI", "isoT", "isoR", "mdrItems"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdf_type.to_s + " . \n" +
      "  ?a isoT:hasIdentifier ?b . \n" +
      "  ?a isoT:hasState ?c . \n" +
      "  ?b isoI:identifier \"" + identifier.to_s + "\" . \n" +
      "  ?b isoI:hasScope #{params[:scope].uri.to_ref} . \n" +
      "  ?c isoR:effectiveDate ?d . \n" +
      "  ?c isoR:untilDate ?e . \n" +
      "  FILTER ( xsd:dateTime(?d) <= \"#{date_time}\"^^xsd:dateTime ) . \n" +
      "  FILTER ( xsd:dateTime(?e) >= \"#{date_time}\"^^xsd:dateTime ) . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    nodes = xmlDoc.xpath("//result")
    if nodes.length == 1
      node = nodes[0]    
      uri = ModelUtility.getValue('a', true, node)
      if uri != "" 
        object = find(ModelUtility.extractCid(uri), ModelUtility.extractNs(uri))
      else
        object = nil
      end
    else
      object = nil
    end
    return object
  end

  # Find the set of current items for a given type
  #
  # @param rdf_type [String] the RDF type
  # @param namespace [String] the schema namespace
  # @return [Array] array of UriV2 objects
  def self.current_set(rdf_type, namespace)    
    results = []
    date_time = Time.now.iso8601.gsub('+',"%2B")
    query = UriManagement.buildNs(namespace, ["isoI", "isoT", "isoR", "mdrItems"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdf_type.to_s + " . \n" +
      "  ?a isoT:hasState ?c . \n" +
      "  ?c isoR:effectiveDate ?d . \n" +
      "  ?c isoR:untilDate ?e . \n" +
      "  FILTER ( xsd:dateTime(?d) <= \"#{date_time}\"^^xsd:dateTime ) . \n" +
      "  FILTER ( xsd:dateTime(?e) >= \"#{date_time}\"^^xsd:dateTime ) . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      results << UriV2.new({ uri: ModelUtility.getValue('a', true, node) })
    end
    return results
  end

  # Find Managed that is the ultimate parent of given an object.
  #
  # @param id [string] the id of the item 
  # @param namespace [string] the namespace of the item
  # @return [URI] The URI of the managed item
  def self.find_managed(id, namespace)
    result = {}
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_T, UriManagement::C_ISO_I, UriManagement::C_ISO_25964, UriManagement::C_BF, UriManagement::C_CBC, UriManagement::C_BD]) +
      "SELECT DISTINCT ?s ?o WHERE \n" +
      "{ \n" +
      "  { \n" +
      "    ?s (iso25964:hasConcept|iso25964:hasChild)* :#{id} . \n" +      
      "    ?s isoT:hasIdentifier ?si . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  } UNION {\n" +
      "    ?s (bf:hasGroup|bf:hasSubGroup|bf:hasItem|bf:hasCommon|bf:hasCommonItem)* :#{id} . \n" +      
      "    ?s isoT:hasIdentifier ?si . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  } UNION {\n" +
      "    ?s (cbc:hasItem|cbc:hasDatatype|cbc:hasProperty|cbc:hasComplexDatatype)* :#{id} . \n" +      
      "    ?s isoT:hasIdentifier ?si . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  } UNION {\n" +
      "    ?s (bd:includesColumn)* :#{id} . \n" +      
      "    ?s isoT:hasIdentifier ?si . \n" +      
      "    ?s rdf:type ?o . \n" +      
      "  }\n" +   
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    nodes = xmlDoc.xpath("//result")
    if nodes.length == 1
      node = nodes[0]    
      uri = UriV2.new({uri: ModelUtility.getValue('s', true, node)})
      rdf_type = ModelUtility.getValue('o', true, node)
      result = { uri: uri, rdf_type: rdf_type }
    end
    return result
  end

  # Add a tag
  #
  # @param id [string] The id of the tag
  # @param namespace [string] The namespace of the tag
  # @raise [Exceptions::UpdateError] if object not updated
  # @return null
  def add_tag(id, namespace)    
    # Create the query
    uri = UriV2.new({:id => id, :namespace => namespace})
    update = UriManagement.buildNs(self.namespace, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + self.id + " isoC:hasMember #{uri.to_ref} . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      ConsoleLogger::info(C_CLASS_NAME, "add_tag", "Failed to add tag to object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Delete a tag
  #
  # @param id [string] The id of the tag
  # @param namespace [string] The namespace of the tag
  # @raise [Exceptions::UpdateError] if object not updated
  # @return null
  def delete_tag(id, namespace)  
    uri = UriV2.new({:id => id, :namespace => namespace})
    update = UriManagement.buildNs(self.namespace, ["isoC"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + self.id + " isoC:hasMember #{uri.to_ref} . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + self.id + " isoC:hasMember #{uri.to_ref} . \n" +
      "}"
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::info(C_CLASS_NAME, "add_tag", "Failed to remove tag from object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Add Branch Parent. Add reference to the parent managed item.
  #
  # @param id [String] The id of the parent managed item
  # @param namespace [String] The namespace of the parent managed item
  # @raise [Exceptions::UpdateError] if object not updated
  # @return null
  def add_branch_parent(id, namespace)    
    sparql = SparqlUpdateV2.new
    ref = OperationalReferenceV2.new
    ref.subject_ref = UriV2.new({id: id, namespace: namespace})
    subject = {:uri => self.uri}
    ref_uri = ref.to_sparql_v2(self.uri, "branchedFrom", "BFR", 1, sparql)
    sparql.triple(subject, {:prefix => UriManagement::C_BO, :id => "branchedFrom"}, {:uri => ref_uri})
    response = CRUD.update(sparql.to_s)
    if !response.success?
      ConsoleLogger::info(C_CLASS_NAME, "add_branch_parent", "Failed to add branch parent.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Branches. Obtains the items branched from this item
  #
  # @param id [String] The id of the item
  # @param namespace [String] The namespace of the item
  # @return [Array] Array of hash, each hash containing the URI and the RDF type of the item found
  def self.branches(id, namespace)
    results = Array.new
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_C, UriManagement::C_BO]) +
      "SELECT DISTINCT ?s WHERE \n" +
      "{\n" +
      "  ?o bo:branchedFrom :#{id} .\n" + 
      "  ?s bo:branchedFrom ?o .\n" + 
      "}"
    response = CRUD.query(query) 
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      s_object = ModelUtility.getValue('s', true, node)
      if !s_object.empty?
        uri = UriV2.new({uri: s_object})
        mi = IsoManaged.find(uri.id, uri.namespace)
        #ConsoleLogger::log(C_CLASS_NAME, "branches", "mi={#{mi.to_json}}.")
        results << mi
      end
    end
    return results
  end

  # Determines if the item can be created
  #
  # @param ra [object] The Registration Authority
  # @return [boolean] True if create is permitted, false otherwise.
  def create_permitted?
    result = true
    exists = exists?
    if self.version == IsoScopedIdentifier.first_version && exists
      result = false
      self.errors.add(:base, "The item cannot be created. The identifier is already in use.")
    elsif self.version == IsoScopedIdentifier.first_version && !exists
      result = true
    elsif self.version != IsoScopedIdentifier.first_version && exists
      if version_exists?
        result = false
        self.errors.add(:base, "The item cannot be created. The identifier and version is already in use.")
      else
        result = true
      end
    elsif self.version != IsoScopedIdentifier.first_version && !exists
      result = false
      self.errors.add(:base, "The item cannot be created. Identifier does not exist but not first version. Logic error.")
      # TODO: Exception here.
    end 
    return result
  end

  # Update the item
  #
  # @params [Hash] The parameters {:explanatoryComment, :changeDescription, :origin}
  # @raise [Exceptions::UpdateError] if an error occurs during the update
  # @return null
  def update(params)  
    date_time = Time.now.iso8601
    update = UriManagement.buildNs(self.namespace, ["isoT"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + self.id + " isoT:explanatoryComment ?a . \n" +
      " :" + self.id + " isoT:changeDescription ?b . \n" +
      " :" + self.id + " isoT:origin ?c . \n" +
      " :" + self.id + " isoT:lastChangeDate ?d . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " :" + self.id + " isoT:explanatoryComment \"" + SparqlUtility::replace_special_chars(params[:explanatoryComment]) + "\"^^xsd:string . \n" +
      " :" + self.id + " isoT:changeDescription \"" + SparqlUtility::replace_special_chars(params[:changeDescription]) + "\"^^xsd:string . \n" +
      " :" + self.id + " isoT:origin \"" + SparqlUtility::replace_special_chars(params[:origin]) + "\"^^xsd:string . \n" +
      " :" + self.id + " isoT:lastChangeDate \"#{SparqlUtility::replace_special_chars(date_time)}\"^^xsd:dateTime . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + self.id + " isoT:explanatoryComment ?a . \n" +
      " :" + self.id + " isoT:changeDescription ?b . \n" +
      " :" + self.id + " isoT:origin ?c . \n" +
      " :" + self.id + " isoT:lastChangeDate ?d . \n" +
      "}"
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end
  
  # Update the item status. If we are moving to a released state then
  # update the semantic version
  #
  # @params [Hash] the parameters
  # @return [Null] errors are in the error object, if any 
  def update_status(params)  
    self.registrationState.update(params)
    if !self.registrationState.errors.empty?
      self.copy_errors(self.registrationState, "Registration State:")
    else
      if self.registrationState.released_state?
        self.scopedIdentifier.update semantic_version: :major
        if !self.scopedIdentifier.errors.empty?
          self.copy_errors(self.scopedIdentifier, "Scoped Identifier:")
        end
      end
    end
  end

  # Destroy the object
  #
  # @raise [Exceptions::DestroyError] if object not destroyed
  # @return [Null]
  def destroy
    # Create the query
    update = UriManagement.buildNs(self.namespace, [C_SCHEMA_PREFIX, "isoI", "isoR", "isoT"]) +
      "DELETE \n" +
      "{\n" +
      "  ?s ?p ?o . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  {\n" +
      "    :" + self.id + " (:|!:)* ?s . \n" +  
      "    ?s ?p ?o . \n" +
      "    FILTER(STRSTARTS(STR(?s), \"" + self.namespace + "\"))" +
      "  } UNION {\n" + 
      "    :" + self.id + " isoT:hasIdentifier ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  } UNION {\n" + 
      "    :" + self.id + " isoT:hasState ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  }\n" + 
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  # Find the items that are linked from or to this managed item.
  #
  # @param from [Boolean] Include the items linked from this item if true. Default true
  # @param to [Boolean] Include the items linked to this item if true. Default true
  # @return [Array] Array of items found.
  def find_links_from_to(from=true, to=true)
    map = {}
    results = find_links(self.id, self.namespace, map, 1, from, to)
  end

  # Create the object from JSON
  #
  # @param json [Hash] The JSON hash.
  # @return [Object] The object created
  def self.from_json(json)
    object = super(json)
    object.origin = json[:origin]
    object.changeDescription = json[:change_description]
    object.creationDate = json[:creation_date].to_time_with_default
    object.lastChangeDate = json[:last_changed_date].to_time_with_default
    object.explanatoryComment = json[:explanatory_comment]
    object.registrationState = IsoRegistrationState.from_json(json[:registration_state])
    object.scopedIdentifier = IsoScopedIdentifier.from_json(json[:scoped_identifier])
    return object
  end

  # Build
  #
  # @param params [Hash] thre operational hash
  # return [Object] the build object
  def self.build(params, ra)
    object = from_json(params[:managed_item])
    object.from_operation(params[:operation], self::C_CID_PREFIX, self::C_INSTANCE_NS, ra)
    object.lastChangeDate = object.creationDate # Make sure we don't set current time.
    object.valid?
    object.create_permitted?
    return object
  end

  # Update the object as directed by the operation
  #
  # @param json [Hash] The JSON hash.
  # @param prefix [String] The prefix for the URI fragment
  # @param instance_namespace [String] The namespace for the URI
  # @param ra [Object] The registration authority object
  # @return [null]
  def from_operation(json, prefix, instance_namespace, ra)
    # Set the new version and new semantic version before RS and SI created
    new_version = json[:new_version].to_i
    semantic_version = SemanticVersion.from_s(json[:new_semantic_version])
    # Ensure base RS and SI set.
    self.scopedIdentifier = IsoScopedIdentifier.from_data(self.identifier, new_version, self.versionLabel, semantic_version, ra.ra_namespace)
    self.registrationState = IsoRegistrationState.from_data(self.identifier, self.version, ra)
    # Now update the version and state based on the operation. Done after base RS and SI created.
    self.registrationState.previousState = self.registrationState.registrationStatus
    self.registrationState.registrationStatus = json[:new_state]
    self.lastChangeDate = Time.now
    # Build the uri. Extend with version, save in the object.
    org_name = ra.ra_namespace.short_name
    uri = UriV2.new(:namespace => instance_namespace, :prefix => prefix, :org_name => org_name, :identifier => self.identifier)  
    uri.extend_path("#{org_name}/V#{self.version}")
    self.namespace = uri.namespace
    self.id = uri.id
  end

  # Adjust Version. Update the version depending on what the next version should be.
  # This is useful for impors where not everything is at the same version.
  #
  # @return [null]
  def adjust_next_version
  	self.scopedIdentifier.version = IsoScopedIdentifier.next_version(self.identifier, self.registrationState.registrationAuthority.ra_namespace)
  end

  # Return the object as SPARQL
  #
  # @param sparql [Object] The sparql object being built
  # @param schema_prefix [String] The schema prefix for the default namespace
  # @return [object] The uri of the object
  def to_sparql_v2(sparql, schema_prefix)
    sparql.default_namespace(self.namespace)
    super(sparql, schema_prefix)
    rs_uri = self.registrationState.to_sparql_v2(sparql)
    si_uri = self.scopedIdentifier.to_sparql_v2(sparql)
    # And the object.
    subject = {:namespace => self.namespace, :id => self.id}
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_I, :id => "hasIdentifier"}, {:uri => si_uri})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "hasState"}, {:uri => rs_uri})
    if !branched_from_ref.nil?
      ref_uri = branched_from_ref.to_sparql_v2(self.uri, "branchedFrom", "BFR", 1, sparql)
      sparql.triple(subject, {:prefix => UriManagement::C_BO, :id => "branchedFrom"}, {:uri => ref_uri})
    end
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_T, :id => "creationDate"}, {:literal => "#{self.creationDate.iso8601}", :primitive_type => "dateTime"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_T, :id => "lastChangeDate"}, {:literal => "#{self.lastChangeDate.iso8601}", :primitive_type => "dateTime"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_T, :id => "changeDescription"}, {:literal => "#{self.changeDescription}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_T, :id => "explanatoryComment"}, {:literal => "#{self.explanatoryComment}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_T, :id => "origin"}, {:literal => "#{self.origin}", :primitive_type => "string"})
    return self.uri
  end

  # Return the object as JSON
  #
  # @return [hash] The JSON hash.
  def to_json
    json = super
    json[:origin] = self.origin
    json[:change_description] = self.changeDescription
    json[:creation_date] = self.creationDate.iso8601
    json[:last_changed_date] = self.lastChangeDate.iso8601
    json[:explanatory_comment] = self.explanatoryComment
    json[:registration_state] = self.registrationState.to_json
    json[:scoped_identifier] = self.scopedIdentifier.to_json
    return json
  end

  # To Operation. Build the combination of managed item and the controlling operation structure
  # 
  # @return [hash] The operational structure
  def to_operation
    managed_item = to_json
    # Set the operation. Based on if a new version is required.
    if new_version?
      managed_item[:creation_date] = Time.now.iso8601
      operation = 
        { :action => "CREATE", 
          :new_version => self.next_version,
          :new_semantic_version => self.next_semantic_version.to_s,
          :new_state => self.state_on_edit, 
          :identifier_edit => false 
        }
      if self.next_version == self.first_version
        operation[:identifier_edit] = true
      end
    else
      operation = 
        { :action => "UPDATE", 
          :new_version => self.version, 
          :new_semantic_version => self.semantic_version.to_s,
          :new_state => self.state_on_edit, 
          :identifier_edit => false 
        }
    end
    result = 
    {
      :operation => operation,
      :managed_item => managed_item
    }
    return result
  end

  # Update Operation. Build the operational structure so as to only update the item.
  # 
  # @return [hash] The operational structure
  def update_operation
    managed_item = to_json
    managed_item[:creation_date] = Time.now.iso8601
    operation = 
      { :action => "UPDATE", 
        :new_version => self.version, 
        :new_semantic_version => self.semantic_version.to_s,
        :new_state => self.state_on_edit, 
        :identifier_edit => false 
      }
    result = 
    {
      :operation => operation,
      :managed_item => managed_item
    }
    return result
  end

  # Import Operation. Builds a managed item operaitonal hash for an import using a blank object.
  #
  # @param [Hash] params the params hash
  # @option params [String] :label the items's label
  # @option params [String] :identifier the items's identifier
  # @option params [String] :version_label the items's version label
  # @option params [String] :semantic_version the items's semantic version
  # @option params [String] :version the items's version (integer as a string)
  # @option params [String] :date the items's release date
  # @option params [Integer] :ordinal the ordinal for the item
  # @return [Boolean] retruns true if sheet check pass, false otherwise with errors added.
  def import_operation(params)
    self.label = params[:label] if self.label.blank?
    self.scopedIdentifier.identifier = params[:identifier]
    self.scopedIdentifier.versionLabel = params[:version_label]
    operation = self.to_operation
    operation[:operation][:new_version] = params[:version]
    operation[:operation][:new_semantic_version] = SemanticVersion.from_s(params[:semantic_version]).to_s
    operation[:operation][:new_state] = IsoRegistrationState.releasedState
    operation[:managed_item][:creation_date] = params[:date]
    operation[:managed_item][:ordinal] = params[:ordinal]
    return operation
  end 

  # To Clone. Clones the object to allow for an item copy to be created.
  # 
  # @return [hash] The JSON structure
  def to_clone
    # To clone, reset RS and SI (resets the version info etc). Then edit.
    # This leaves current content intact but resets version info.
    # Allow the identifier to be edited.
    self.scopedIdentifier = IsoScopedIdentifier.new
    self.registrationState = IsoRegistrationState.new
    result = to_operation
    result[:operation][:identifier_edit] = true
    return result
  end

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    super_valid = super
    rs_valid = self.registrationState.valid?
    if !rs_valid
      ConsoleLogger::log(C_CLASS_NAME,"valid?","RS")
      self.registrationState.errors.full_messages.each do |msg|
        self.errors[:base] << "Registration State error: #{msg}"
      end
    end
    si_valid = self.scopedIdentifier.valid?
    if !si_valid
      ConsoleLogger::log(C_CLASS_NAME,"valid?","SI")
      self.scopedIdentifier.errors.full_messages.each do |msg|
        self.errors[:base] << "Scoped Identifier error: #{msg}"
      end
    end
    result = super_valid &&
      rs_valid &&
      si_valid &&
      FieldValidation.valid_markdown?(:change_description, self.changeDescription, self) &&
      FieldValidation.valid_markdown?(:explanatory_comment, self.explanatoryComment, self) &&
      FieldValidation.valid_markdown?(:origin, self.origin, self) 
    return result
  end

  # Import Params Valid. Check the import parameters.
  #
  # @params [Hash] params a hash of parameters
  # @option params [String] :version the version, integer
  # @option params [String] :date, a valid date
  # @option params [String] :files, at least one file
  # @option params [String] :semantic_version, a valid semantic version
  # @return [Errors] active record errors class
  def self.import_params_valid?(params)
    object = self.new
    FieldValidation::valid_version?(:version, params[:version], object)
    FieldValidation::valid_date?(:date, params[:date], object)
    FieldValidation::valid_files?(:files, params[:files], object)
    FieldValidation::valid_semantic_version?(:semantic_version, params[:semantic_version], object)
    return object
  end

private

  def self.query_and_response(query)
    # Query
    response = CRUD.query(query) 
    # Process the response.
    triples = Hash.new { |h,k| h[k] = [] }
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      subject = ModelUtility.getValue('s', true, node)
      predicate = ModelUtility.getValue('p', true, node)
      objectUri = ModelUtility.getValue('o', true, node)
      objectLiteral = ModelUtility.getValue('o', false, node)
      if predicate != ""
        triple_object = objectUri
        if triple_object == ""
          triple_object = objectLiteral
        end
        key = ModelUtility.extractCid(subject)
        triples[key] << {:subject => subject, :predicate => predicate, :object => triple_object}
      end
    end
    return triples
  end

  # Find the links from and to the managed item.
  def find_links(id, namespace, map, hop, from = true, to = true)
    results = []
    concepts = []
    return results if hop > APP_CONFIG['max_impact_hops'].to_i
    item = IsoManaged.find(id, namespace, false)
    # Dont expand if a terminology, just blows up.
    if item.rdf_type != Thesaurus::C_RDF_TYPE_URI.to_s
      uri = UriV2.new({id: id, namespace: namespace})
      map[uri.to_s] = true
      concepts += IsoConcept.links_from(id, namespace) if from
      concepts += IsoConcept.links_to(id, namespace) if to
      concepts.each do |concept|
        concept_uri = concept[:uri]
        if !map.has_key?(concept_uri.to_s)
          if concept[:local]
            results += find_links(concept_uri.id, concept_uri.namespace, map, (hop + 1), from, to)
          else
            mi = IsoManaged.find_managed(concept_uri.id, concept_uri.namespace)
            mi_uri = mi[:uri]
            if !mi_uri.nil? 
              if !map.has_key?(mi_uri.to_s)
                managed_item = IsoManaged.find(mi_uri.id, mi_uri.namespace, false)
                results << { uri: mi_uri, rdf_type: managed_item.rdf_type, label: managed_item.label }
                map[mi_uri.to_s] = true
              end
            else
              ConsoleLogger.info(C_CLASS_NAME, "merge", "Failed to find managed item, URI=#{uri}")
            end
          end
        end
        map[concept_uri.to_s] = true
      end
    end
    return results
  end

end