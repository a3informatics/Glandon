require "nokogiri"
require "uri"

class IsoManaged < IsoConcept

  include CRUD
  include ModelUtility
  
  attr_accessor :registrationState, :scopedIdentifier, :origin, :changeDescription, :creationDate, :lastChangedDate, :explanatoryComment, :tag_refs

  # Constants
  C_CID_PREFIX = "ISOM"
  C_CLASS_NAME = "IsoManaged"
  C_SCHEMA_PREFIX = "isoC"
  C_INSTANCE_PREFIX = "mdrItems"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)

  def initialize(triples=nil, id=nil)
    if triples.nil?
      super
      self.origin = ""
      self.changeDescription = ""
      self.creationDate = Time.now
      self.lastChangedDate = Time.now
      self.explanatoryComment = ""
      self.triples = ""
      self.registrationState = IsoRegistrationState.new
      self.scopedIdentifier = IsoScopedIdentifier.new
      self.tag_refs = Array.new
    else
      super(triples, id)
      if self.link_exists?(UriManagement::C_ISO_I, "hasIdentifier")
        links = self.get_links(UriManagement::C_ISO_I, "hasIdentifier")
        cid = ModelUtility.extractCid(links[0])
        self.scopedIdentifier = IsoScopedIdentifier.new(triples[cid])
        if self.link_exists?(UriManagement::C_ISO_R, "hasState")
          links = self.get_links(UriManagement::C_ISO_R, "hasState")
          cid = ModelUtility.extractCid(links[0])
          self.registrationState= IsoRegistrationState.new(triples[cid])
        end
      end
      self.tag_refs = self.get_links(UriManagement::C_ISO_C, "hasMember")  
    end    
  end  

  def version
    return self.scopedIdentifier.version
  end

  def versionLabel
    return self.scopedIdentifier.versionLabel
  end

  def identifier
    return self.scopedIdentifier.identifier
  end

  def latest?
    latest_version = IsoScopedIdentifier.latest(self.identifier, self.owner_id)
    return self.version == latest_version
  end

  def later_version?(version)
    return self.scopedIdentifier.later_version?(version)
  end
  
  def earlier_version?(version)
    return self.scopedIdentifier.earlier_version?(version)
  end
  
  def same_version?(version)
    return self.scopedIdentifier.same_version?(version)
  end
  
  def owner
    return self.scopedIdentifier.owner
  end

  def owner_id
    return self.scopedIdentifier.owner_id
  end

  def registrationStatus
    if self.registrationState == nil
      #ConsoleLogger::log(C_CLASS_NAME,"registrationStatus","rs=na")
      return "na"
    else
      #ConsoleLogger::log(C_CLASS_NAME,"registrationStatus","rs=" + self.registrationState.registrationStatus.to_s)
      return self.registrationState.registrationStatus
    end
  end

  def registered?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.registered?
    end
  end

  def edit?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.edit?
    end
  end

  def delete?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.delete?
    end
  end

  def new_version?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.new_version?
    end
  end

  def state_on_edit
    if self.registrationState == nil
      return IsoRegistrationState.no_state
    else
      return self.registrationState.state_on_edit
    end
  end

  def can_be_current?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.can_be_current?
    end
  end

  def next_version
    self.scopedIdentifier.next_version
  end

  def first_version
    self.scopedIdentifier.first_version
  end

  def current?
    if self.registrationState == nil
      return false
    else
      return self.registrationState.current
    end
  end

  # Does the item exist. Cannot be used for child objects!
  def self.exists?(identifier, registrationAuthority)
    result = IsoScopedIdentifier.exists?(identifier, registrationAuthority.namespace.id)
  end

  # Does the item exist. Cannot be used for child objects!
  def exists?(registrationAuthority)
    result = IsoScopedIdentifier.exists?(self.identifier, registrationAuthority.namespace.id)
  end

  # Does the version exist. Cannot be used for child objects!
  def self.versionExists?(identifier, version, namespace)
    result = IsoScopedIdentifier.versionExists?(identifier, version, namespace.id)
  end

  # Note: The id is the identifier for the enclosing managed object. 
  def self.find(id, ns, full=true)  
    # Initialise.
    object = nil
    # Create the query and action.
    query = UriManagement.buildNs(ns, [UriManagement::C_ISO_I, UriManagement::C_ISO_R]) +
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
      "    :" + id + " isoI:hasIdentifier ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  } UNION {\n" +
      "    :" + id + " isoR:hasState ?s . \n" +
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
    return object   
  end

  # Find list of managed items of a given type.
  def self.unique(rdfType, ns)
    results = IsoScopedIdentifier.allIdentifier(rdfType, ns)
  end

  # Find all managed items based on their type.
  def self.all(rdfType, ns)
    results = Array.new
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h ?i WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?i . \n" +
      "  OPTIONAL { \n" +
      "    ?a isoI:hasIdentifier ?h . \n" +
      "    OPTIONAL { \n" +
      "      ?a isoR:hasState ?b . \n" +
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
            object.creationDate = dateSet[0].text
            object.lastChangedDate = lastSet[0].text
            object.explanatoryComment = commentSet[0].text
          else
            object.registrationState = nil
            object.origin = ""
            object.changeDescription = ""
            object.creationDate = ""
            object.lastChangedDate = ""
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

  # Find all managed items based on tag settings.
  def self.find_by_tag(id, namespace)
    results = Array.new
    # Create the query
    uri = UriV2.new({:id => id, :namespace => namespace})
    query = UriManagement.buildNs(namespace, ["isoI", "isoC"]) +
      "SELECT ?a ?b ?c ?d ?e WHERE \n" +
      "{ \n" +
      "  ?a rdfs:label ?b . \n" +
      "  ?a isoC:hasMember #{uri.to_ref} . \n" +
      "  ?a isoI:hasIdentifier ?d . \n" +
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

  # Find history for a given identifier
  def self.history(rdfType, ns, params)    
    identifier = params[:identifier]
    namespace_id = params[:scope_id]
    results = Array.new
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR", "mdrItems"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h ?i ?j WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType.to_s + " . \n" +
      "  ?a rdfs:label ?i . \n" +
      "  ?a isoI:hasIdentifier ?h . \n" +
      "  ?h isoI:identifier \"" + identifier.to_s + "\" . \n" +
      "  ?h isoI:hasScope mdrItems:" + namespace_id.to_s + " . \n" +
      "  ?h isoI:version ?j . \n" +
      "  OPTIONAL { \n" +
      "    ?a isoR:hasState ?b . \n" +
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
        object.rdf_type = rdfType
        object.label = label
        object.origin = oSet[0].text
        object.changeDescription = descSet[0].text
        object.creationDate = dateSet[0].text
        object.lastChangedDate = lastSet[0].text
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

  # Find latest item for all identifiers of a given type.
  # TODO: Needs to be updated with current mechanism
  def self.list(rdfType, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"list","*****Entry*****")    
    check = Hash.new
    results = Array.new

    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?d . \n" +
      "  ?a isoI:hasIdentifier ?b . \n" +
      "  ?b isoI:identifier ?e . \n" +
      "  ?b isoI:hasScope ?h . \n" +
      "  ?b isoI:version ?f . \n" +
      "  OPTIONAL { \n" +
      "    ?a isoR:hasState ?c . \n" +
      "    ?c isoR:registrationStatus ?g . \n" +
      "  } \n" +
      "} ORDER BY DESC(?f)"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('d', false, node)
      identifier = ModelUtility.getValue('e', false, node)
      version = ModelUtility.getValue('f', false, node)
      status = ModelUtility.getValue('g', false, node)
      scope = ModelUtility.getValue('h', true, node)
      #ConsoleLogger::log(C_CLASS_NAME,"list","node=" + node.to_s)
      if uri != "" 
        scope_namespace = IsoNamespace.find(ModelUtility.extractCid(scope))
        key = scope_namespace.shortName + "_" + identifier
        if check.has_key?(key)
          object = check[key]
          if (object.registrationState != nil) && (status != "")
            if (object.registrationState.registrationStatus != IsoRegistrationState.releasedState) &&
              (status == IsoRegistrationState.releasedState)
              object = self.new
              object.id = ModelUtility.extractCid(uri)
              object.namespace = ModelUtility.extractNs(uri)
              object.rdf_type = rdfType
              object.label = label
              object.scopedIdentifier = IsoScopedIdentifier.new
              object.scopedIdentifier.identifier = identifier
              object.registrationState = IsoRegistrationState.new
              object.registrationState.registrationStatus = status
              check[key] = object
            end
          end
        else
          object = self.new
          object.id = ModelUtility.extractCid(uri)
          object.namespace = ModelUtility.extractNs(uri)
          object.rdf_type = rdfType
          object.label = label
          object.scopedIdentifier = IsoScopedIdentifier.new
          object.scopedIdentifier.identifier = identifier
          if status == ""
            object.registrationState = nil
          else
            object.registrationState = IsoRegistrationState.new
            object.registrationState.registrationStatus = status
          end
          check[key] = object
        end
      end
    end
    results = check.values
    return results  
  end

  def self.current(rdfType, ns, params)    
    #ConsoleLogger::log(C_CLASS_NAME,"latest","*****Entry*****")    
    identifier = params[:identifier]
    namespace_id = params[:scope_id]
    date_time = Time.now
    results = Array.new
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR", "mdrItems"]) +
      "SELECT ?a ?b ?c ?d ?e WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType.to_s + " . \n" +
      "  ?a isoI:hasIdentifier ?b . \n" +
      "  ?a isoR:hasState ?c . \n" +
      "  ?b isoI:identifier \"" + identifier.to_s + "\" . \n" +
      "  ?b isoI:hasScope mdrItems:" + namespace_id.to_s + " . \n" +
      "  ?c isoR:effectiveDate ?d . \n" +
      "  ?c isoR:untilDate ?e . \n" +
      "  FILTER ( ?d <= \"" + date_time + "\"^^xsd:dateTime ) . \n" +
      "  FILTER ( ?e >= \"" + date_time + "\"^^xsd:dateTime ) . \n" +
      "  } \n" +
      "} ORDER BY DESC(?e)"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    if xmlDoc.xpath("//result").length > 0
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
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create","Success, id=" + self.id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"create", "Failed to create object.")
      raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
    end
  end

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
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      raise Exceptions::CreateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Rewritten to return an object with the desired settings for the import.
  def self.import(prefix, params, ownerNamespace, rdfType, schemaNs, instanceNs)
    identifier = params[:identifier]
    version = params[:version]
    version_label = params[:versionLabel]
    # Set the registration authority to teh owner
    orgName = ownerNamespace.shortName
    scopeId = ownerNamespace.id
    # Create the required namespace. Use owner name to extend
    uri = ModelUtility::version_namespace(version, instanceNs, orgName)
    useNs = uri.getNs()
    ConsoleLogger::log(C_CLASS_NAME,"create","useNs=" + useNs)
    # Create the SI, RS etc.
    identifier = params[:identifier]
    object = self.new
    object.id = ModelUtility.build_full_cid(prefix, orgName, identifier)
    object.namespace = useNs
    object.scopedIdentifier = IsoScopedIdentifier.create_dummy(identifier, version, version_label, ownerNamespace)
    object.registrationState = IsoRegistrationState.create_dummy(identifier, version, ownerNamespace)
    return object
  end

  def self.create_permitted?(identifier, version, object, ra)
    result = true
    exists = exists?(identifier, ra)
    org_name = ra.namespace.shortName
    scope = ra.namespace
    if version == IsoScopedIdentifier.first_version && exists
      result = false
      object.errors.add(:base, "The item cannot be created. The identifier is already in use.")
    elsif version == IsoScopedIdentifier.first_version && !exists
      result = true
    elsif version != IsoScopedIdentifier.first_version && exists
      if versionExists?(identifier, version, scope)
        result = false
        object.errors.add(:base, "The item cannot be created. The identifier and version is already in use.")
      else
        result = true
      end
    elsif version != IsoScopedIdentifier.first_version && !exists
      result = false
      object.errors.add(:base, "The item cannot be created. Identifier does not exist but not first version. Logic error.")
      # TODO: Exception here.
    end 
    return result
  end

  def create_permitted?(ra)
    result = true
    exists = self.exists?(ra)
    org_name = ra.namespace.shortName
    scope = ra.namespace
    ConsoleLogger::log(C_CLASS_NAME,"create_permitted?", "Version=#{self.version}, Exists?=#{exists}")
    if self.version == IsoScopedIdentifier.first_version && exists
      result = false
      self.errors.add(:base, "The item cannot be created. The identifier is already in use.")
    elsif self.version == IsoScopedIdentifier.first_version && !exists
      result = true
    elsif self.version != IsoScopedIdentifier.first_version && exists
      if versionExists?(self.identifier, self.version, scope)
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

  #def self.create(prefix, params, rdfType, schemaNs, instanceNs)
  #  identifier = params[:identifier]
  #  version = params[:version]
  #  version_label = params[:versionLabel]
  #  # Set the registration authority to teh owner
  #  ra = IsoRegistrationAuthority.owner
  #  orgName = ra.namespace.shortName
  #  scopeId = ra.namespace.id
  #  # Create the required namespace. Use owner name to extend
  #  uri = ModelUtility::version_namespace(version, instanceNs, orgName)
  #  useNs = uri.getNs()
  #  # Set the timestamp
  #  timestamp = Time.now.iso8601
  #  # Create the object
  #  object = self.new
  #  object.id = ModelUtility.buildCidIdentifier(prefix, identifier)
  #  object.namespace = useNs
  #  object.scopedIdentifier = IsoScopedIdentifier.create(identifier, version, version_label, ra.namespace)
  #  object.registrationState = IsoRegistrationState.create(identifier, version, ra.namespace)
  #  object.origin = ""
  #  object.changeDescription = "Creation"
  #  object.creationDate = timestamp
  #  object.lastChangedDate = timestamp
  #  object.explanatoryComment = ""
  #  object.label = params[:label]
  #  object.rdf_type = rdfType
  #  prefixSet = ["mdrItems", "isoT", "isoI", "isoR"]
  #  schemaPrefix = UriManagement.getPrefix(schemaNs)
  #  prefixSet << schemaPrefix
  #  update = UriManagement.buildNs(useNs, prefixSet) +
  #    "INSERT DATA \n" +
  #    "{ \n" +
  #    "  :" + object.id + " isoI:hasIdentifier mdrItems:" + object.scopedIdentifier.id + " . \n" +
  #    "  :" + object.id + " isoR:hasState mdrItems:" + object.registrationState.id + " . \n" +
  #    "  :" + object.id + " isoT:origin \"\"^^xsd:string . \n" +
  #    "  :" + object.id + " isoT:changeDescription \"Creation\"^^xsd:string . \n" +
  #    "  :" + object.id + " isoT:creationDate \"" + timestamp.to_s + "\"^^xsd:string . \n" +
  #    "  :" + object.id + " isoT:lastChangeDate \"\"^^xsd:string . \n" +
  #    "  :" + object.id + " isoT:explanatoryComment \"\"^^xsd:string . \n" +
  #    "  :" + object.id + " rdf:type " + schemaPrefix + ":" + rdfType + " . \n" +
  #    "  :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
  #  "}"
  #  # Send the request, wait the resonse
  #  response = CRUD.update(update)
  #  # Response
  #  if response.success?
  #    ConsoleLogger::log(C_CLASS_NAME,"create","Success, id=" + object.id)
  #  else
  #    ConsoleLogger::log(C_CLASS_NAME,"create", "Failed to create object.")
  #    raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
  #  end
  #  return object
  #end 

  def to_json
    json = super
    json[:origin] = self.origin
    json[:change_description] = self.changeDescription = ""
    json[:creation_date] = self.creationDate = Time.now
    json[:last_changed_date] = self.lastChangedDate = Time.now
    json[:explanatory_comment] = self.explanatoryComment = ""
    json[:registration_state] = self.registrationState.to_json
    json[:scoped_identifier] = self.scopedIdentifier.to_json
    return json
  end

  def self.from_json(json)
    # Get the json structures and the updated versionand state
    operation = json[:operation]
    managed_item = json[:managed_item]
    # Create the object
    object = super(managed_item)
    object.origin = managed_item[:origin]
    object.changeDescription = managed_item[:change_description]
    object.creationDate = managed_item[:creation_date]
    object.lastChangedDate = managed_item[:last_changed_date]
    object.explanatoryComment = managed_item[:explanatory_comment]
    object.registrationState = IsoRegistrationState.from_json(managed_item[:registration_state])
    object.scopedIdentifier = IsoScopedIdentifier.from_json(managed_item[:scoped_identifier])
    # Update the version and state based on the operation
    object.scopedIdentifier.version = operation[:new_version].to_i
    object.registrationState.previousState = object.registrationState.registrationStatus
    object.registrationState.registrationStatus = operation[:new_state]
    # Finish
    return object
  end

  def to_sparql(sparql, ra, prefix, instance_namespace, schema_prefix)
    # Get the timestamp
    timestamp = Time.now.iso8601
    # Set the organisation
    org_name = ra.namespace.shortName
    # Build the uri. Extend with version, save in the object and set as the default namespace.
    uri = UriV2.new(:namespace => instance_namespace, :prefix => prefix, :org_name => org_name, :identifier => self.identifier)  
    uri.extend_path("#{org_name}/V#{self.version}")
    self.namespace = uri.namespace
    self.id = uri.id
    sparql.add_default_namespace(self.namespace)
    # Build the sparql. The concept and then the registration state and scoped identifier
    super(sparql, schema_prefix)
    rs_id = self.registrationState.to_sparql(sparql, ra, self.identifier, self.version)
    si_id = self.scopedIdentifier.to_sparql(sparql, ra)
    # And the object.
    sparql.triple("", self.id, UriManagement::C_ISO_I, "hasIdentifier", C_INSTANCE_PREFIX, si_id)
    sparql.triple("", self.id, UriManagement::C_ISO_R, "hasState", C_INSTANCE_PREFIX, rs_id)
    sparql.triple_primitive_type("", self.id, UriManagement::C_ISO_T, "creationDate", "#{self.creationDate}", "string")
    sparql.triple_primitive_type("", self.id, UriManagement::C_ISO_T, "lastChangeDate", "#{timestamp}", "string")
    sparql.triple_primitive_type("", self.id, UriManagement::C_ISO_T, "changeDescription", "#{self.changeDescription}", "string")
    sparql.triple_primitive_type("", self.id, UriManagement::C_ISO_T, "explanatoryComment", "#{self.explanatoryComment}", "string")
    sparql.triple_primitive_type("", self.id, UriManagement::C_ISO_T, "origin", "#{self.origin}", "string")
    return uri
  end

  # Build the SPARQL for the managed item creation.
  def self.create_sparql(prefix, params, rdfType, schemaNs, instanceNs, sparql, ra)
    operation = params[:operation]
    managed_item = params[:managed_item]
    version = operation[:new_version]
    new_state = operation[:new_state]
    previous_state = managed_item[:state]
    identifier = managed_item[:identifier]
    version_label = managed_item[:version_label]
    #ConsoleLogger::log(C_CLASS_NAME,"create_sparql","Version Label=" + managed_item.to_json.to_s)
    timestamp = Time.now.iso8601
    schema_prefix = UriManagement.getPrefix(schemaNs)
    # Set the registration authority to the owner
    org_name = ra.namespace.shortName
    scopeId = ra.namespace.id
    # Create the required namespace. Use owner name to extend
    uri = ModelUtility::version_namespace(version, instanceNs, org_name)
    useNs = uri.getNs()
    # Dummy SI and RS to get the right identifiers.
    #dummy_SI = IsoScopedIdentifier.create_dummy(identifier, version, version_label, ra.namespace)
    #dummy_RS = IsoRegistrationState.create_dummy(identifier, version, ra.namespace)
    id = ModelUtility.build_full_cid(prefix, org_name, identifier)
    # SI and RS
    si_id = IsoScopedIdentifier.create_sparql(identifier, version, version_label, ra.namespace, sparql)
    rs_id = IsoRegistrationState.create_sparql(identifier, version, new_state, previous_state, ra, sparql)
    # And the object.
    sparql.add_default_namespace(useNs)
    sparql.triple("", id, UriManagement::C_RDF, "type", schema_prefix, rdfType)
    sparql.triple("", id, UriManagement::C_ISO_I, "hasIdentifier", C_INSTANCE_PREFIX, si_id)
    sparql.triple("", id, UriManagement::C_ISO_R, "hasState", C_INSTANCE_PREFIX, rs_id)
    sparql.triple_primitive_type("", id, UriManagement::C_RDFS, "label", managed_item[:label], "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "creationDate", managed_item[:creation_date], "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "lastChangeDate", timestamp.to_s, "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "changeDescription", managed_item[:change_description], "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "explanatoryComment", managed_item[:comment], "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "origin", managed_item[:references], "string")
    # Result URI
    uri = Uri.new
    uri.setNsCid(useNs, id)
    return uri
  end

  def update(params)  
    comment = 
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
      " :" + self.id + " isoT:lastChangeDate \"" + date_time.to_s + "\"^^xsd:dateTime . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + self.id + " isoT:explanatoryComment ?a . \n" +
      " :" + self.id + " isoT:changeDescription ?b . \n" +
      " :" + self.id + " isoT:origin ?c . \n" +
      " :" + self.id + " isoT:lastChangeDate ?d . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      raise Exceptions::CreateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end
  
  def destroy(namespace)
    # Create the query
    update = UriManagement.buildNs(namespace, [C_SCHEMA_PREFIX, "isoI", "isoR"]) +
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
      "    :" + self.id + " isoI:hasIdentifier ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  } UNION {\n" + 
      "    :" + self.id + " isoR:hasState ?s . \n" +
      "    ?s ?p ?o . \n" +
      "  }\n" + 
      "}\n"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  def to_api_json
    #ConsoleLogger::log(C_CLASS_NAME,"to_api_json","*****Entry*****")
    result = 
    { 
      :type => "",
      :id => self.id, 
      :namespace => self.namespace, 
      :identifier => self.identifier, 
      :label => self.label, 
      :version => self.version,
      :version_label => self.versionLabel,
      :state => self.registrationStatus,
      :creation_date => self.creationDate,
      :last_changed_date => self.lastChangedDate,
      :change_description => self.changeDescription,
      :comment => self.explanatoryComment,
      :references => self.origin,
      :children => [] 
    }
    return result
  end

  def to_edit(v2=false)
    result = 
    {
      :operation => {},
      :managed_item => {}
    }
    # Get the managed item, new and old versions
    if v2
      managed_item = to_json
    else
      managed_item = to_api_json
    end
    # Set the operation
    if new_version?
      managed_item[:creation_date] = Time.now.iso8601
      result[:operation] = { :action => "CREATE", :new_version => self.next_version, :new_state => self.state_on_edit, :identifier_edit => false }
      if self.next_version == self.first_version
        result[:operation][:identifier_edit] = true
      end
    else
      result[:operation] = { :action => "UPDATE", :new_version => self.version, :new_state => self.state_on_edit, :identifier_edit => false }
    end
    result[:managed_item] = managed_item
    #ConsoleLogger::log(C_CLASS_NAME,"to_edit","Result=" + result.to_s)
    return result
  end

  def self.create_json
    result = 
    {
      :operation => { 
        :action => "CREATE", 
        :new_version => IsoScopedIdentifier.first_version, 
        :new_state => IsoRegistrationState.releasedState, 
        :identifier_edit => false 
      },
      :managed_item => { 
        :type => "",
        :id => "", 
        :namespace => "", 
        :identifier => "", 
        :label => "", 
        :version => IsoScopedIdentifier.first_version, 
        :version_label => "",
        :state => IsoRegistrationState.releasedState, 
        :creation_date => Time.now.iso8601,
        :last_changed_date => Time.now.iso8601,
        :change_description => "",
        :comment => "",
        :references => "",
        :children => [] 
      }
    }
    return result
  end

  def to_clone(v2=false)
    # To clone, reset RS and SI (resets the version info etc). Then edit.
    # This leaves current content intact but resets version info.
    # Allow the identifier to be edited.
    self.scopedIdentifier = IsoScopedIdentifier.new
    self.registrationState = IsoRegistrationState.new
    result = to_edit(v2)
    result[:operation][:identifier_edit] = true
    ConsoleLogger::log(C_CLASS_NAME,"to_clone","Result=" + result.to_s)
    return result
  end

  def get_property(type)
    results = get(prefix, type)
    if results.length == 1
      return results[0]
    else
      result = {}
      return result
    end
  end

end