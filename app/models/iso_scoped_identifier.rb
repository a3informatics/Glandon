require "nokogiri"
require "uri"

class IsoScopedIdentifier

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :versionLabel, :version, :namespace
  validates_presence_of :identifier, :versionLabel, :version, :namespace
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CLASS_PREFIX = "SI"
  C_CLASS_NAME = "IsoScopedIdentifier"
        
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def baseNs
    return @@baseNs 
  end
  
  def owner
    return self.namespace.shortName
  end
  
  def self.exists?(identifier, scopeId)
    
    ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"exists?","Identifier=" + identifier.to_s )
    ConsoleLogger::log(C_CLASS_NAME,"exists?","ScopeId=" + scopeId.to_s )
    result = false
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:ScopedIdentifier . \n" +
      "  ?a isoI:identifier \"" + identifier + "\" . \n" +
      "  ?a isoI:hasScope :" + scopeId + ". \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      if uri != "" 
        ConsoleLogger::log(C_CLASS_NAME,"exists?","exisits")
        result = true
      end
    end
    return result

  end

  def self.find(id)
    
    object = nil
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b ?c ?d ?e WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:identifier ?b . \n" +
      "  :" + id + " isoI:versionLabel ?c . \n" +
      "  :" + id + " isoI:version ?d . \n" +
      "  :" + id + " isoI:hasScope ?e . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      iSet = node.xpath("binding[@name='b']/literal")
      vlSet = node.xpath("binding[@name='c']/literal")
      vSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/uri")
      if iSet.length == 1 and vlSet.length == 1 and vSet.length == 1
        object = self.new 
        object.id = id
        object.identifier = iSet[0].text
        object.version = (vSet[0].text).to_i
        object.versionLabel = vlSet[0].text
        object.namespace = IsoNamespace.find(ModelUtility.extractCid(sSet[0].text))
        ConsoleLogger::log(C_CLASS_NAME,"find","Object=" + id)
      end
      
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a ?b ?c ?d ?e WHERE \n" +
        "{ \n" +
        "	 ?a rdf:type isoI:ScopedIdentifier . \n" +
        "  ?a isoI:identifier ?b . \n" +
        "	 ?a isoI:versionLabel ?c . \n" +
        "  ?a isoI:version ?d . \n" +
        "  ?a isoI:hasScope ?e . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"all","Node=" + node.to_s)
      uriSet = node.xpath("binding[@name='a']/uri")
      iSet = node.xpath("binding[@name='b']/literal")
      vlSet = node.xpath("binding[@name='c']/literal")
      vSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/uri")
      if uriSet.length == 1 and vlSet.length == 1 and iSet.length == 1 and vSet.length == 1 and sSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = iSet[0].text
        object.version = (vSet[0].text).to_i
        object.versionLabel = vlSet[0].text
        object.namespace = IsoNamespace.find(ModelUtility.extractCid(sSet[0].text))
        ConsoleLogger::log(C_CLASS_NAME,"all","Created object=" + object.id)
        results.push (object)
      end
    end
    
    return results
    
  end

  # Find all managed items of a given type by unique identifier.
  def self.allIdentifier(rdfType, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"all","*****Entry*****")
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT DISTINCT ?d WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  OPTIONAL { \n" +
      "    ?a isoI:hasIdentifier ?c . \n" +
      "    ?c isoI:identifier ?d . \n" +
      "  } \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      # uri = ModelUtility.getValue('a', true, node)
      # label = ModelUtility.getValue('b', false, node)
      # si = ModelUtility.getValue('c', true, node)
      identifier = ModelUtility.getValue('d', false, node)
      if identifier != "" 
        results << identifier
      end
    end
    
    # Return
    return results
    
  end

  def self.create(params, uid, scopeId)
    
    # Get the parameters from the user. 
    versionLabel = params[:versionLabel]
    version = params[:version]
    identifier = params[:identifier]
    ConsoleLogger::log(C_CLASS_NAME,"create","*****ENTRY*****")
    ConsoleLogger::log(C_CLASS_NAME,"create",
      "ScopeId=" + scopeId + ", " + 
      "versionLabel=" + versionLabel + ", " + 
      "version=" + version + ", " + 
      "identifier" + identifier + ", " + 
      "itemUid=" + uid )
        
    # Create the CID
    id = ModelUtility.buildCidIdentifierVersion(C_CLASS_PREFIX, uid, version)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	 :" + id + " isoI:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:version \"" + version.to_s + "\"^^xsd:positiveInteger . \n" +
      "  :" + id + " isoI:versionLabel \"" + versionLabel.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:hasScope :" + scopeId.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.version = version
      object.versionLabel = versionLabel
      object.identifier = identifier
      object.namespace = IsoNamespace.find(scopeId)
    else
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def update(id)
    return nil
  end

  def destroy
    
    # Log
    ConsoleLogger::log(C_CLASS_NAME,"destroy","Id=" + self.id)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI"]) +
      "DELETE \n" +
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "}\n"

    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Process response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Deleted")
    else
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Error!")
    end
    
  end

end