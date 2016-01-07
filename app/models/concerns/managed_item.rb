require "nokogiri"
require "uri"

class ManagedItem

  include CRUD
  include ModelUtility
      
  attr_accessor :id, :namespace, :type, :label, :comment, :registrationState, :scopedIdentifier, :origin, :changeDescription, :creationDate, :lastChangedDate, :explanoratoryComment
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CLASS_NAME = "ManagedItem"
  C_AI = 1
  C_II = 2
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
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

  def self.exists?(identifier)
    
    ra = RegistrationAuthority.owner
    ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"exists?","Namespace=" + ra.namespace.id)
    result = IsoScopedIdentifier.exists?(identifier, ra.namespace.id)

  end

  def self.imported?(identifier, org)
    
    #ra = RegistrationAuthority.owner
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","Namespace=" + ra.namespace.id)
    #result = ScopedIdentifier.exists?(identifier, ra.namespace.id)

  end

  # Note: The id is the identifier for the enclosing managed object.
  def self.find(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    object = nil
    #ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    #ConsoleLogger::log(C_CLASS_NAME,"find","namespace=" + useNs + " [base=" + @@baseNs + "]")
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:hasIdentifier ?a . \n" +
      "  OPTIONAL { \n" +
      "    :" + id + " rdfs:label ?h . \n" +
      "    OPTIONAL { \n" +
      "      :" + id + " isoI:hasState ?b . \n" +
      "      :" + id + " isoT:origin ?c . \n" +
      "      :" + id + " isoT:changeDescription ?d . \n" +
      "      :" + id + " isoT:creationDate ?e . \n" +
      "      :" + id + " isoT:lastChangeDate  ?f . \n" +
      "      :" + id + " isoT:explanatoryComment ?g . \n" +
      "    } \n" +
      "  } \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      iiSet = node.xpath("binding[@name='a']/uri")
      rsSet = node.xpath("binding[@name='b']/uri")
      oSet = node.xpath("binding[@name='c']/literal")
      descSet = node.xpath("binding[@name='d']/literal")
      dateSet = node.xpath("binding[@name='e']/literal")
      lastSet = node.xpath("binding[@name='f']/literal")
      commentSet = node.xpath("binding[@name='g']/literal")
      label = ModelUtility.getValue('h', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","Label=" + label)
      if iiSet.length == 1 
        object = self.new
        object.id = id
        object.namespace = ns
        object.label = label
        object.scopedIdentifier = IsoScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
        if rsSet.length == 1
          object.registrationState = IsoRegistrationState.find(ModelUtility.extractCid(rsSet[0].text))
          object.origin = oSet[0].text
          object.changeDescription = descSet[0].text
          object.creationDate = dateSet[0].text
          object.lastChangedDate = lastSet[0].text
          object.explanoratoryComment = commentSet[0].text
          object.type = C_AI
        else
          object.registrationState = nil
          object.origin = ""
          object.changeDescription = ""
          object.creationDate = ""
          object.lastChangedDate = ""
          object.explanoratoryComment = ""
          object.type = C_II
        end
      end
    end
    
    # Return
    return object
    
  end

  def self.import(prefix, params, scopeId, ns)
  
    ConsoleLogger::log(C_CLASS_NAME,"createImported","*****Entry*****")
    
    useNs = ns || @@baseNs
    uid = ModelUtility.createUid
    params[:itemUid] = uid
    
    ConsoleLogger::log(C_CLASS_NAME,"createLocal","useNs=" + useNs)
    
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, uid)
    object.scopedIdentifier = IsoScopedIdentifier.create(params, uid, scopeId)
    object.registrationState = nil
    object.type = C_II
    object.origin = ""
    object.changeDescription = ""
    object.creationDate = ""
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
    object.label = ""

    update = UriManagement.buildNs(useNs, ["mdrItems", "isoI"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + object.id + " isoI:hasIdentifier mdrItems:" + object.scopedIdentifier.id + " . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create_imported","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create_imported","Failed")
    end
    return object
  
  end

  def self.create(prefix, params, baseNs)

    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
   
    version = params[:version]

    # Set the registration authority to teh owner
    ra = RegistrationAuthority.owner
    orgName = ra.namespace.shortName
    scopeId = ra.namespace.id

    # Create the required namespace. Use owener name to extend
    uri = Uri.new
    uri.setUri(baseNs)
    uri.extendPath(orgName + "/V" + version.to_s)
    useNs = uri.getNs()
    ConsoleLogger::log(C_CLASS_NAME,"create","useNs=" + useNs)
     
    # Create the uid based on the identifier. Identifier has to be unique
    # (checked using exists?) thsi will clean out any nastry unwanted chars 
    uid = ModelUtility.createUid(params[:identifier])
    timestamp = Time.now
    
    # Create the object
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, uid)
    object.namespace = useNs
    object.scopedIdentifier = IsoScopedIdentifier.create(params, uid, scopeId)
    object.registrationState = IsoRegistrationState.create(params, uid)
    object.type = C_AI
    object.origin = ""
    object.changeDescription = "Creation"
    object.creationDate = timestamp
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
    object.label = params[:label]

    update = UriManagement.buildNs(useNs, ["mdrItems", "isoT", "isoI"]) +
      "INSERT DATA \n" +
      "{ \n" +
      " :" + object.id + " isoI:hasIdentifier mdrItems:" + object.scopedIdentifier.id + " . \n" +
      " :" + object.id + " isoI:hasState mdrItems:" + object.registrationState.id + " . \n" +
      " :" + object.id + " isoT:origin \"\"^^xsd:string . \n" +
      " :" + object.id + " isoT:changeDescription \"Creation\"^^xsd:string . \n" +
      " :" + object.id + " isoT:creationDate \"" + timestamp.to_s + "\"^^xsd:string . \n" +
      " :" + object.id + " isoT:lastChangeDate \"\"^^xsd:string . \n" +
      " :" + object.id + " isoT:explanatoryComment \"\"^^xsd:string . \n" +
      " :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
    #  " :" + object.id + " rdfs:comment \"\"^^xsd:string . \n" +
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

  def self.count(prefix, type)

    result = {}
    
    # Create the query
    query = UriManagement.buildPrefix(prefix, ["isoI", "isoB"]) +
      "SELECT ?orgSN (COUNT(?s) as ?count) WHERE \n" +
      "{ \n" +
      "  ?s rdf:type :" + type + " . \n" +
      "  ?s isoI:hasIdentifier ?si . \n" +
      "  ?si isoI:hasScope ?ns . \n" +
      "  ?ns isoI:ofOrganization ?org . \n" +
      "  ?org isoB:shortName ?orgSN . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    result[:type] = type
    xmlDoc.xpath("//result").each do |node|
      orgSN = ModelUtility.getValue('orgSN', false, node)
      count = ModelUtility.getValue('count', false, node)
      result[orgSN] = count
    end
    return result

  end

  def update(id)
    return nil
  end

  def destroy
    return nil
  end

end