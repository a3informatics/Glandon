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
  C_CID_PREFIX  = "SI"
  C_CLASS_NAME = "IsoScopedIdentifier"
  C_FIRST_VERSION = 1

  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def initialize
    self.id = ""
    self.identifier = ""
    self.versionLabel = ""
    self.version = 0
    self.namespace = ""
  end

  def persisted?
    id.present?
  end
 
  def baseNs
    return @@baseNs 
  end
  
  def owner
    return self.namespace.shortName
  end
  
  def owner_id
    return self.namespace.id
  end
  
  def next_version
    return version + 1
  end
  
  def self.later_version?(version_1, version_2)
    return version_1 >= version_2
  end
  
  def first_version
    return C_FIRST_VERSION
  end
  
  def self.first_version
    return C_FIRST_VERSION
  end
  
  def self.exists?(identifier, scopeId)   
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","Identifier=" + identifier.to_s )
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","ScopeId=" + scopeId.to_s )
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

  def self.versionExists?(identifier, version, scopeId)   
    #ConsoleLogger::log(C_CLASS_NAME,"versionExists?","*****Entry*****")
    #ConsoleLogger::log(C_CLASS_NAME,"versionExists?","Identifier=" + identifier.to_s )
    #ConsoleLogger::log(C_CLASS_NAME,"versionExists?","Version=" + version.to_s )
    #ConsoleLogger::log(C_CLASS_NAME,"versionExists?","ScopeId=" + scopeId.to_s )
    result = false
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:ScopedIdentifier . \n" +
      "  ?a isoI:identifier \"" + identifier + "\" . \n" +
      "  ?a isoI:version " + version.to_s + " . \n" +
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
        ConsoleLogger::log(C_CLASS_NAME,"versionExists?","exisits")
        result = true
      end
    end
    return result
  end

  def self.find(id)    
    object = nil
    #ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    
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
        #ConsoleLogger::log(C_CLASS_NAME,"find","Object=" + id)
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
      #ConsoleLogger::log(C_CLASS_NAME,"all","Node=" + node.to_s)
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
        #ConsoleLogger::log(C_CLASS_NAME,"all","Created object=" + object.id)
        results.push (object)
      end
    end    
    return results
    
  end

  # Find all managed items of a given type by unique identifier.
  # Uses hash for results rather than object as results are a hybrid.
  def self.allIdentifier(rdfType, ns)
    results = Array.new
    check = Hash.new

    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT DISTINCT ?d ?e ?f WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a isoI:hasIdentifier ?c . \n" +
      "  ?a rdfs:label ?e . \n" +
      "  ?c isoI:identifier ?d . \n" +
      "  ?c isoI:hasScope ?f . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      identifier = ModelUtility.getValue('d', false, node)
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('e', false, node)
      scope = ModelUtility.getValue('f', true, node)
      if identifier != "" 
        scope_namespace = IsoNamespace.find(ModelUtility.extractCid(scope))
        key = scope_namespace.shortName + "_" + identifier
        if !check.has_key?(key)
          results << {:identifier => identifier, :label => label, :owner_id => scope_namespace.id, :owner => scope_namespace.shortName}
          check[key] = key
        end
      end
    end
    return results    
  end

  def self.create(identifier, version, version_label, scope_org)

    # Create the CID
    id = ModelUtility.build_full_cid(C_CID_PREFIX, scope_org.shortName, identifier, version)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	 :" + id + " isoI:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:version \"" + version.to_s + "\"^^xsd:positiveInteger . \n" +
      "  :" + id + " isoI:versionLabel \"" + version_label.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:hasScope :" + scope_org.id.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.version = version
      object.versionLabel = version_label
      object.identifier = identifier
      object.namespace = scope_org
    else
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def self.create_dummy(identifier, version, version_label, scope_org)
    object = self.new
    object.id = ModelUtility.build_full_cid(C_CID_PREFIX , scope_org.shortName, identifier, version)
    object.version = version
    object.versionLabel = version_label
    object.identifier = identifier
    object.namespace = scope_org
    return object
  end

  def self.create_sparql(identifier, version, version_label, scope_org, sparql)
    id = ModelUtility.build_full_cid(C_CID_PREFIX , scope_org.shortName, identifier, version)
    sparql.add_prefix("isoI")
    sparql.triple(C_NS_PREFIX, id, "rdf", "type", "isoI", "ScopedIdentifier")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoI", "identifier", identifier.to_s, "string")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoI", "version", version.to_s, "positiveInteger")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoI", "versionLabel", version_label.to_s, "string")
    sparql.triple(C_NS_PREFIX, id, "isoI", "hasScope", C_NS_PREFIX, scope_org.id.to_s)
  end

  def destroy
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