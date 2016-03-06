require "nokogiri"
require "uri"

class IsoManaged < IsoConcept

  include CRUD
  include ModelUtility
  
  attr_accessor :registrationState, :scopedIdentifier, :origin, :changeDescription, :creationDate, :lastChangedDate, :explanoratoryComment
  
  # Constants
  C_CID_PREFIX = "ISOM"
  C_CLASS_NAME = "IsoManaged"
  C_SCHEMA_PREFIX = "isoC"
  C_INSTANCE_PREFIX = "mdrItems"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def version
    return self.scopedIdentifier.version
  end

  def versionLabel
    return self.scopedIdentifier.versionLabel
  end

  def identifier
    return self.scopedIdentifier.identifier
  end

  def owner
    return self.scopedIdentifier.owner
  end

  def registrationStatus
    if registrationState == nil
      return "na"
    else
      return self.registrationState.registrationStatus
    end
  end

  def registered?
    return registrationState != nil
  end

  def edit?
    if registrationState == nil
      return false
    else
      return self.registrationState.edit?
    end
  end

  def delete?
    if registrationState == nil
      return false
    else
      return self.registrationState.delete?
    end
  end

  def new_version?
    if registrationState == nil
      return false
    else
      return self.registrationState.new_version?
    end
  end

  def next_version
    scopedIdentifier.next_version
  end

  def first_version
    scopedIdentifier.first_version
  end

  # Does the item exist. Cannot be used for child objects!
  def self.exists?(identifier, registrationAuthority)
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","Namespace=" + registrationAuthority.namespace.id)
    result = IsoScopedIdentifier.exists?(identifier, registrationAuthority.namespace.id)
  end

  # Does the item exist. Cannot be used for child objects!
  def self.versionExists?(identifier, version, namespace)
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","Namespace=" + registrationAuthority.namespace.id)
    result = IsoScopedIdentifier.versionExists?(identifier, version, namespace.id)
  end

  # Note: The id is the identifier for the enclosing managed object. 
  def self.find(id, ns)  
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    ConsoleLogger::log(C_CLASS_NAME,"find","namespace=" + ns)   
    object = super(id, ns)
    object.registrationState = nil
    object.origin = ""
    object.changeDescription = ""
    object.creationDate = ""
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
    object.scopedIdentifier = nil
    object.registrationState = nil
    #object.rdfType = object.properties.get("rdf", "type")
    #object.label = object.properties.get("rdfs", "label")
    if object.links.exists?("isoI", "hasIdentifier")
      links = object.links.get("isoI", "hasIdentifier")
      cid = ModelUtility.extractCid(links[0])
      object.scopedIdentifier = IsoScopedIdentifier.find(cid)
      if object.links.exists?("isoR", "hasState")
        links = object.links.get("isoR", "hasState")
        cid = ModelUtility.extractCid(links[0])
        object.registrationState = IsoRegistrationState.find(cid)
        object.origin = object.properties.get("isoT", "origin")
        object.changeDescription = object.properties.get("isoT", "changeDescription")
        object.creationDate = object.properties.get("isoT", "creationDate")
        object.lastChangedDate = object.properties.get("isoT", "lastChangeDate")
        object.explanoratoryComment = object.properties.get("isoT", "explanoratoryComment") 
      end
    end
    
    # Return
    #ConsoleLogger::log(C_CLASS_NAME,"find","Object return, object=" + object.to_s)
    return object   
  end

  # Find list of managed items of a given type.
  def self.unique(rdfType, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + ns.to_s)
    results = IsoScopedIdentifier.allIdentifier(rdfType, ns)
  end

  # Find all managed items based on their type.
  def self.all(rdfType, ns)
    
    #ConsoleLogger::log(C_CLASS_NAME,"all","*****Entry*****")
    
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
      #ConsoleLogger::log(C_CLASS_NAME,"find","Label=" + label)
      if uri != "" 
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdfType = rdfType
        object.label = label
        if iiSet.length == 1
          object.scopedIdentifier = IsoScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
          if rsSet.length == 1
            object.registrationState = IsoRegistrationState.find(ModelUtility.extractCid(rsSet[0].text))
            object.origin = oSet[0].text
            object.changeDescription = descSet[0].text
            object.creationDate = dateSet[0].text
            object.lastChangedDate = lastSet[0].text
            object.explanoratoryComment = commentSet[0].text
          else
            object.registrationState = nil
            object.origin = ""
            object.changeDescription = ""
            object.creationDate = ""
            object.lastChangedDate = ""
            object.explanoratoryComment = ""
          end
        else
          object.scopedIdentifier = nil
        end
        results << object
      end
    end
    
    # Return
    return results
    
  end

  # Find history for a given identifier
  def self.history(rdfType, identifier, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"history","*****Entry*****")    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h ?i ?j WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?i . \n" +
      # "  OPTIONAL { \n" +
      "    ?a isoI:hasIdentifier ?h . \n" +
      "    ?h isoI:identifier \"" + identifier + "\" . \n" +
      "    ?h isoI:version ?j . \n" +
      "    OPTIONAL { \n" +
      "      ?a isoR:hasState ?b . \n" +
      "      ?a isoT:origin ?c . \n" +
      "      ?a isoT:changeDescription ?d . \n" +
      "      ?a isoT:creationDate ?e . \n" +
      "      ?a isoT:lastChangeDate  ?f . \n" +
      "      ?a isoT:explanatoryComment ?g . \n" +
      "    } \n" +
      # "  } \n" +
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
      #ConsoleLogger::log(C_CLASS_NAME,"history","Label=" + label)
      if uri != "" 
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdfType = rdfType
        object.label = label
        if iiSet.length == 1
          object.scopedIdentifier = IsoScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
          if rsSet.length == 1
            object.registrationState = IsoRegistrationState.find(ModelUtility.extractCid(rsSet[0].text))
            object.origin = oSet[0].text
            object.changeDescription = descSet[0].text
            object.creationDate = dateSet[0].text
            object.lastChangedDate = lastSet[0].text
            object.explanoratoryComment = commentSet[0].text
          else
            object.registrationState = nil
            object.origin = ""
            object.changeDescription = ""
            object.creationDate = ""
            object.lastChangedDate = ""
            object.explanoratoryComment = ""
          end
        else
          object.scopedIdentifier = nil
        end
        results << object
      end
    end
    
    # Return
    return results  
  end

  # Find latest item for all identifiers.
  def self.list(rdfType, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"list","*****Entry*****")    
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT", "isoR"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?d . \n" +
      "  ?a isoI:hasIdentifier ?b . \n" +
      "  ?b isoI:identifier ?e . \n" +
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
      #ConsoleLogger::log(C_CLASS_NAME,"list","node=" + node.to_s)
      if uri != "" 
        if results.has_key?(identifier)
          object = results[identifier]
          if (object.registrationState != nil) && (status != "")
            if (object.registrationState.registrationStatus != IsoRegistrationState.releasedState) &&
              (status == IsoRegistrationState.releasedState)
              object = self.new
              object.id = ModelUtility.extractCid(uri)
              object.namespace = ModelUtility.extractNs(uri)
              object.rdfType = rdfType
              object.label = label
              object.registrationState.registrationStatus = status
              results[identifier] = object
            end
          end
        else
          object = self.new
          object.id = ModelUtility.extractCid(uri)
          object.namespace = ModelUtility.extractNs(uri)
          object.rdfType = rdfType
          object.label = label
          object.scopedIdentifier = IsoScopedIdentifier.new
          object.scopedIdentifier.identifier = identifier
          if status == ""
            object.registrationState = nil
          else
            object.registrationState = IsoRegistrationState.new
            object.registrationState.registrationStatus = status
          end
          results[identifier] = object
        end
      end
    end
    return results  
  end

  def self.latest(history)
    result = nil
    history.each do |item|
      result = item
      if item.registered?
        break if item.registrationState.registrationStatus == IsoRegistrationState.releasedState
      else
        break
      end
    end
    return result
  end

  # Rewritten to return an object with the desired settings for the import.
  def self.import(prefix, params, ownerNamespace, rdfType, schemaNs, instanceNs)
    #ConsoleLogger::log(C_CLASS_NAME,"import","*****Entry*****")
    identifier = params[:identifier]
    version = params[:version]
    version_label = params[:versionLabel]

    # Set the registration authority to teh owner
    orgName = ownerNamespace.shortName
    scopeId = ownerNamespace.id

    # Create the required namespace. Use owner name to extend
    #uri = Uri.new
    #uri.setUri(instanceNs)
    #uri.extendPath(orgName + "/V" + version.to_s)
    uri = ModelUtility::version_namespace(version, instanceNs, orgName)
    useNs = uri.getNs()
    ConsoleLogger::log(C_CLASS_NAME,"create","useNs=" + useNs)
     
    # Create the SI etc. Note no registration state.
    identifier = params[:identifier]
    object = self.new
    object.id = ModelUtility.build_full_cid(prefix, orgName, identifier)
    object.namespace = useNs
    object.scopedIdentifier = IsoScopedIdentifier.create_dummy(identifier, version, version_label, ownerNamespace)
    return object
  end

  def self.create_permitted?(identifier, version, object)
    result = true
    exists = exists?(identifier, IsoRegistrationAuthority.owner)
    ra = IsoRegistrationAuthority.owner
    org_name = ra.namespace.shortName
    scope = ra.namespace
    ConsoleLogger::log(C_CLASS_NAME,"create_permitted","identifier=" + identifier + ", version=" + version.to_s + ", exists=" + exists.to_s)
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
      # TO DO: Exception here.
    end 
    return result
  end

  def self.create(prefix, params, rdfType, schemaNs, instanceNs)
    #ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    identifier = params[:identifier]
    version = params[:version]
    version_label = params[:versionLabel]

    # Set the registration authority to teh owner
    ra = IsoRegistrationAuthority.owner
    orgName = ra.namespace.shortName
    scopeId = ra.namespace.id

    # Create the required namespace. Use owner name to extend
    #uri = Uri.new
    #uri.setUri(instanceNs)
    #uri.extendPath(orgName + "/V" + version.to_s)
    uri = ModelUtility::version_namespace(version, instanceNs, orgName)
    useNs = uri.getNs()
    ConsoleLogger::log(C_CLASS_NAME,"create","useNs=" + useNs)
     
    # Set the timestamp
    timestamp = Time.now
    
    # Create the object
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, identifier)
    object.namespace = useNs
    object.scopedIdentifier = IsoScopedIdentifier.create(identifier, version, version_label, ra.namespace)
    object.registrationState = IsoRegistrationState.create(identifier, version, ra.namespace)
    object.origin = ""
    object.changeDescription = "Creation"
    object.creationDate = timestamp
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
    object.label = params[:label]
    object.rdfType = rdfType
    prefixSet = ["mdrItems", "isoT", "isoI", "isoR"]
    schemaPrefix = UriManagement.getPrefix(schemaNs)
    prefixSet << schemaPrefix
    update = UriManagement.buildNs(useNs, prefixSet) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + object.id + " isoI:hasIdentifier mdrItems:" + object.scopedIdentifier.id + " . \n" +
      "  :" + object.id + " isoR:hasState mdrItems:" + object.registrationState.id + " . \n" +
      "  :" + object.id + " isoT:origin \"\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:changeDescription \"Creation\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:creationDate \"" + timestamp.to_s + "\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:lastChangeDate \"\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:explanatoryComment \"\"^^xsd:string . \n" +
      "  :" + object.id + " rdf:type " + schemaPrefix + ":" + rdfType + " . \n" +
      "  :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create","Success, id=" + object.id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end

    return object

  end 

  def self.create_sparql(prefix, params, rdfType, schemaNs, instanceNs, sparql)
    #ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    version = params[:new_version]
    identifier = params[:identifier]
    version_label = params[:versionLabel]
    timestamp = Time.now
    schema_prefix = UriManagement.getPrefix(schemaNs)

    # Set the registration authority to the owner
    ra = IsoRegistrationAuthority.owner
    org_name = ra.namespace.shortName
    scopeId = ra.namespace.id

    # Create the required namespace. Use owner name to extend
    uri = ModelUtility::version_namespace(version, instanceNs, org_name)
    useNs = uri.getNs()
    ConsoleLogger::log(C_CLASS_NAME,"create_sparql","useNs=" + useNs)
    
    dummy_SI = IsoScopedIdentifier.create_dummy(identifier, version, version_label, ra.namespace)
    dummy_RS = IsoRegistrationState.create_dummy(identifier, version, ra.namespace)
    id = ModelUtility.build_full_cid(prefix, org_name, identifier)
    
    IsoScopedIdentifier.create_sparql(identifier, version, version_label, ra.namespace, sparql)
    IsoRegistrationState.create_sparql(identifier, version, ra.namespace, sparql)
    sparql.add_default_namespace(useNs)
    #sparql.add_prefix(UriManagement::C_ISO_R)
    #sparql.add_prefix(UriManagement::C_ISO_I)
    #sparql.add_prefix(UriManagement::C_ISO_T)
    #sparql.add_prefix(UriManagement::C_MDR_ITEMS)
    sparql.triple("", id, UriManagement::C_RDF, "type", schema_prefix, rdfType)
    sparql.triple("", id, UriManagement::C_ISO_I, "hasIdentifier", C_INSTANCE_PREFIX, dummy_SI.id)
    sparql.triple("", id, UriManagement::C_ISO_R, "hasState", C_INSTANCE_PREFIX, dummy_RS.id)
    sparql.triple_primitive_type("", id, UriManagement::C_RDFS, "label", params[:label], "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "explanatoryComment", "", "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "lastChangeDate", "", "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "creationDate", timestamp.to_s, "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "changeDescription", "Creation", "string")
    sparql.triple_primitive_type("", id, UriManagement::C_ISO_T, "origin", "", "string")

    # Result URI
    uri = Uri.new
    uri.setNsCid(useNs, id)
    return uri
  end

end