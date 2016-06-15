require "nokogiri"
require "uri"

class IsoScopedIdentifier

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :versionLabel, :version, :namespace
  #validates_presence_of :identifier, :versionLabel, :version, :namespace
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CID_PREFIX  = "SI"
  C_CLASS_NAME = "IsoScopedIdentifier"
  C_FIRST_VERSION = 1

  # Class variables
  @@baseNs

  def initialize(triples=nil)
    @@baseNs ||= UriManagement.getNs(C_NS_PREFIX)
    if triples.nil?
      self.id = ""
      self.namespace = nil
      self.identifier = ""
      self.versionLabel = ""
      self.version = 0
    else
      self.id = ModelUtility.extractCid(triples[0][:subject])
      self.namespace = nil
      if Triples::link_exists?(triples, UriManagement::C_ISO_I, "hasScope")
        links = Triples::get_links(triples, UriManagement::C_ISO_I, "hasScope")
        cid = ModelUtility.extractCid(links[0])
        self.namespace = IsoNamespace.find(cid)
      end
      triples.each do |triple|
        self.identifier = Triples::get_property_value(triples, UriManagement::C_ISO_I, "identifier")
        self.version = Triples::get_property_value(triples, UriManagement::C_ISO_I, "version").to_i
        self.versionLabel = Triples::get_property_value(triples, UriManagement::C_ISO_I, "versionLabel")
      end
    end
  end

  def persisted?
    id.present?
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
  
  def later_version?(version)
    return self.version > version
  end
  
  def earlier_version?(version)
    return self.version < version
  end
  
  def same_version?(version)
    return self.version == version
  end
  
  def first_version
    return C_FIRST_VERSION
  end
  
  def self.first_version
    return C_FIRST_VERSION
  end
  
  # Find if the identifier exists within the specified scope (namespace).
  #
  # * *Args*    :
  #   - +identifier+ -> The identifer being checked.
  #   - +scopeId+ -> The id of the scope namespace (IsoNamespace object)
  # * *Returns* :
  #   - Boolean  
  def self.exists?(identifier, scopeId)   
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
        #ConsoleLogger::log(C_CLASS_NAME,"versionExists?","exisits")
        result = true
      end
    end
    return result
  end

  def self.latest(identifier, scopeId)   
    result = false
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:ScopedIdentifier . \n" +
      "  ?a isoI:identifier \"" + identifier + "\" . \n" +
      "  ?a isoI:version ?b . \n" +
      "  ?a isoI:hasScope :" + scopeId + ". \n" +
      "} ORDER BY DESC(?b)"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      latest_version = ModelUtility.getValue('b', false, node)
      if latest_version != "" 
        ConsoleLogger::log(C_CLASS_NAME,"latest","Latest: #{latest_version}")
        return latest_version.to_i
      end
    end
    return C_FIRST_VERSION
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

  # Find the set of unique identifiers for a given RDF Type
  #
  # * *Args*    :
  #   - +rdfType+ -> The RDF type to be searched for.
  #   - +ns+ -> The namespace within with the search is to take place.
  # * *Returns* :
  #   - Array of hashes. Each hash contains {identifier, label, owner id, owner short name}
  def self.allIdentifier(rdfType, ns)
    results = Array.new
    check = Hash.new
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT DISTINCT ?d ?e ?f ?g WHERE \n" +
      "{\n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a isoI:hasIdentifier ?c . \n" +
      "  ?a rdfs:label ?e . \n" +
      "  ?c isoI:identifier ?d . \n" +
      "  ?c isoI:version ?g . \n" +
      "  ?c isoI:hasScope ?f . \n" +
      "} ORDER BY DESC(?g)"
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
    # Create the query and submit.
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	 :" + id + " isoI:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:version \"" + version.to_s + "\"^^xsd:positiveInteger . \n" +
      "  :" + id + " isoI:versionLabel \"" + version_label.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:hasScope :" + scope_org.id.to_s + " . \n" +
      "}"
    response = CRUD.update(update)
    # Process the response
    if response.success?
      object = self.new
      object.id = id
      object.version = version
      object.versionLabel = version_label
      object.identifier = identifier
      object.namespace = scope_org
    else
      ConsoleLogger::log(C_CLASS_NAME,"create", "Failed to create object.")
      raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
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

  def update(params)  
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + self.id + " isoI:versionLabel ?a . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " :" + self.id + " isoI:versionLabel \"" + params[:versionLabel].to_s + "\"^^xsd:string . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + self.id + " isoI:versionLabel ?a . \n" +
      "}"
    # Send the request, wait the resonse
    ConsoleLogger::log(C_CLASS_NAME,"update", "Update=" + update.to_s)
    response = CRUD.update(update)
    # Response
    if !response.success?
      raise Exceptions::CreateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  def destroy
    # Create the query and submit
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI"]) +
      "DELETE \n" +
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "}\n"
    response = CRUD.update(update)
    # Process the response
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

end