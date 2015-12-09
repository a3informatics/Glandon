require "nokogiri"
require "uri"

class IsoItem

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :id, :namespace, :rdfType, :label, :comment, :registrationState, :scopedIdentifier, :origin, :changeDescription, :creationDate, :lastChangedDate, :explanoratoryComment
  
  # Constants
  C_SCHEMA_PREFIX = "isoC"
  C_INSTANCE_PREFIX = "mdrItems"
  C_CLASS_NAME = "IsoItem"
  C_Administered = 1
  C_Identified = 2
  C_Designatable = 3
  C_Other = 4
  
  # Base namespace 
  @@schemaNs = UriManagement.getNs(C_SCHEMA_PREFIX)
  @@instanceNs = UriManagement.getNs(C_INSTANCE_PREFIX)
  
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
      return ""
    else
      return self.registrationState.registrationStatus
    end
  end

  # Does the item exist. Cannot be used for child objects!
  def self.exists?(identifier, registrationAuthority)
    ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"exists?","Namespace=" + registrationAuthority.namespace.id)
    result = ScopedIdentifier.exists?(identifier, registrationAuthority.namespace.id)
  end

  # Note: The id is the identifier for the enclosing managed object. 
  def self.find(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    
    # Initialise
    object = nil
    
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    ConsoleLogger::log(C_CLASS_NAME,"find","namespace=" + ns)
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h ?i WHERE \n" +
      "{ \n" +
      "  :" + id + " rdf:type ?i . \n" +
      "  :" + id + " rdfs:label ?h . \n" +
      "  OPTIONAL { \n" +
      "    :" + id + " isoI:hasIdentifier ?a . \n" +
      "    OPTIONAL { \n" +
      "      :" + id + " isoI:hasState ?b . \n" +
      "      :" + id + " isoT:origin ?c . \n" +
      "      :" + id + " isoT:changeDescription ?d . \n" +
      "      :" + id + " isoT:creationDate ?e . \n" +
      "      :" + id + " isoT:lastChangedDate  ?f . \n" +
      "      :" + id + " isoT:explanoratoryComment ?g . \n" +
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
      rdfType = ModelUtility.getValue('i', true, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","rdfType=" + rdfType)
      if rdfType != ""
        object = self.new
        object.id = id
        object.namespace = ns
        object.label = label
        object.rdfType = rdfType
        ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        if iiSet.length == 1
          object.scopedIdentifier = ScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
          if rsSet.length == 1
            object.registrationState = RegistrationState.find(ModelUtility.extractCid(rsSet[0].text))
            object.origin = oSet[0].text
            object.changeDescription = descSet[0].text
            object.creationDate = dateSet[0].text
            object.lastChangedDate = lastSet[0].text
            object.explanoratoryComment = commentSet[0].text
            #object.isoType = C_Administered
          else
            object.registrationState = nil
            object.origin = ""
            object.changeDescription = ""
            object.creationDate = ""
            object.lastChangedDate = ""
            object.explanoratoryComment = ""
            #object.isoType = C_Identified
          end
        end
      end
    end
    
    # Return
    ConsoleLogger::log(C_CLASS_NAME,"find","Object return, object=" + object.to_s)
    return object
    
  end

  def self.all(rdfType, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"all","*****Entry*****")
    
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g ?h ?i WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?i . \n" +
      "  OPTIONAL { \n" +
      "    ?a isoI:hasIdentifier ?h . \n" +
      "    OPTIONAL { \n" +
      "      ?a isoI:hasState ?b . \n" +
      "      ?a isoT:origin ?c . \n" +
      "      ?a isoT:changeDescription ?d . \n" +
      "      ?a isoT:creationDate ?e . \n" +
      "      ?a isoT:lastChangedDate  ?f . \n" +
      "      ?a isoT:explanoratoryComment ?g . \n" +
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
      ConsoleLogger::log(C_CLASS_NAME,"find","Label=" + label)
      if uri != "" && label != ""
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdfType = rdfType
        object.label = label
        if iiSet.length == 1
          object.scopedIdentifier = ScopedIdentifier.find(ModelUtility.extractCid(iiSet[0].text))
          if rsSet.length == 1
            object.registrationState = RegistrationState.find(ModelUtility.extractCid(rsSet[0].text))
            object.origin = oSet[0].text
            object.changeDescription = descSet[0].text
            object.creationDate = dateSet[0].text
            object.lastChangedDate = lastSet[0].text
            object.explanoratoryComment = commentSet[0].text
            #object.isoType = C_Administered
          else
            object.registrationState = nil
            object.origin = ""
            object.changeDescription = ""
            object.creationDate = ""
            object.lastChangedDate = ""
            object.explanoratoryComment = ""
            #object.isoType = C_Identified
          end
        else
          object.scopedIdentifier = nil
          #object.isoType = C_Child
        end
        results[object.id] = object
      end
    end
    
    # Return
    return results
    
  end

  def self.createOtherItem(prefix, params, rdfType, schemaNs, instanceNs)
  
    ConsoleLogger::log(C_CLASS_NAME,"createOtherItem","*****Entry*****")
    
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, params[:identifier])
    object.scopedIdentifier = nil
    object.registrationState = nil
    #object.isoType = C_Other
    object.origin = ""
    object.changeDescription = ""
    object.creationDate = ""
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
    object.label = ""
    object.rdfType = params[:rdfType]

    prefixSet = ["mdrItems", "isoI"]
    prefixSet << UriManagement.getPrefix(schemaNs)
    update = UriManagement.buildNs(instanceNs, prefixSet) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + object.id + " rdf:type :" + object.rdfType + " . \n" +
      "  :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"import","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"import","Failed")
    end
    return object
  
  end

  def self.createIdentifiedItem(prefix, params, scopeId, rdfType, schemaNs, instanceNs)
  
    ConsoleLogger::log(C_CLASS_NAME,"createImport","*****Entry*****")
    
    identifier = params[:identifier]
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, identifier)
    object.scopedIdentifier = ScopedIdentifier.create(params, identifier, scopeId)
    object.registrationState = nil
    #object.isoType = C_Identified
    object.origin = ""
    object.changeDescription = ""
    object.creationDate = ""
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
    object.label = params[:label]
    object.rdfType = rdfType

    prefixSet = ["mdrItems", "isoI"]
    schemaPrefix = UriManagement.getPrefix(schemaNs)
    prefixSet << schemaPrefix
    update = UriManagement.buildNs(instanceNs, prefixSet) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + object.id + " isoI:hasIdentifier mdrItems:" + object.scopedIdentifier.id + " . \n" +
      "  :" + object.id + " rdf:type " + schemaPrefix + ":" + rdfType + " . \n" +
      "  :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"import","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"import","Failed")
    end
    return object
  
  end

  def self.createAdministeredItem(prefix, params, rdfType, schemaNs, instanceNs)

    ConsoleLogger::log(C_CLASS_NAME,"createAdministeredItem","*****Entry*****")
   
    version = params[:version]

    # Set the registration authority to teh owner
    ra = RegistrationAuthority.owner
    orgName = ra.namespace.shortName
    scopeId = ra.namespace.id

    # Create the required namespace. Use owner name to extend
    uri = Uri.new
    uri.setUri(instanceNs)
    uri.extendPath(orgName + "/V" + version.to_s)
    useNs = uri.getNs()
    ConsoleLogger::log(C_CLASS_NAME,"createAdministeredItem","useNs=" + useNs)
     
    # Set the timestamp
    timestamp = Time.now
    
    # Create the object
    identifier = params[:identifier]
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, identifier)
    object.namespace = useNs
    object.scopedIdentifier = ScopedIdentifier.create(params, identifier, scopeId)
    object.registrationState = RegistrationState.create(params, identifier)
    #object.isoType = C_Administered
    object.origin = ""
    object.changeDescription = "Creation"
    object.creationDate = timestamp
    object.lastChangedDate = ""
    object.explanoratoryComment = ""
    object.label = params[:label]
    object.rdfType = rdfType

    prefixSet = ["mdrItems", "isoT", "isoI"]
    schemaPrefix = UriManagement.getPrefix(schemaNs)
    prefixSet << schemaPrefix
    update = UriManagement.buildNs(useNs, prefixSet) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + object.id + " isoI:hasIdentifier mdrItems:" + object.scopedIdentifier.id + " . \n" +
      "  :" + object.id + " isoI:hasState mdrItems:" + object.registrationState.id + " . \n" +
      "  :" + object.id + " isoT:origin \"\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:changeDescription \"Creation\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:creationDate \"" + timestamp.to_s + "\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:lastChangedDate \"\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:explanoratoryComment \"\"^^xsd:string . \n" +
      "  :" + object.id + " rdf:type " + schemaPrefix + ":" + rdfType + " . \n" +
      "  :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
    "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"createAdministeredItem","Success, id=" + object.id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"createAdministeredItem","Failed")
    end

    return object

  end 

end