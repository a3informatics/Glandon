require "nokogiri"
require "uri"

class IsoScopedIdentifier

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :versionLabel, :version, :semantic_version, :namespace
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CID_PREFIX  = "SI"
  C_CLASS_NAME = "IsoScopedIdentifier"
  C_FIRST_VERSION = 1

  # Class variables
  @@base_namespace

  # Clean an Identifier. Cleans unwanted characters from an identifier string
  #
  # @param identifier [String] the dirty identifier
  # @return [String] the clean identifier
  def self.clean_identifier(identifier)
    identifier.gsub(/[^A-Z0-9a-z ]/i, ' ').upcase.strip
  end

  # Initialize the object (new)
  # 
  # @param triples [array] Arrays of triples
  # @return [string] The owner's short name
  def initialize(triples=nil)
    @@base_namespace ||= UriManagement.getNs(C_NS_PREFIX)
    if triples.nil?
      self.id = ""
      self.namespace = IsoNamespace.new
      self.identifier = ""
      self.versionLabel = ""
      self.version = 0
      self.semantic_version = SemanticVersion.new({})
    else
      self.id = ModelUtility.extractCid(triples[0][:subject])
      self.namespace = nil
      if Triples.link_exists?(triples, UriManagement::C_ISO_I, "hasScope")
        links = Triples.get_links(triples, UriManagement::C_ISO_I, "hasScope")
        #cid = ModelUtility.extractCid(links[0])
        self.namespace = IsoNamespace.find(Uri.new(uri: links.first.to_s))
      end
      self.identifier = Triples.get_property_value(triples, UriManagement::C_ISO_I, "identifier")
      self.version = Triples.get_property_value(triples, UriManagement::C_ISO_I, "version").to_i
      self.versionLabel = Triples.get_property_value(triples, UriManagement::C_ISO_I, "versionLabel")
      self.semantic_version = SemanticVersion.from_s(Triples.get_property_value(triples, UriManagement::C_ISO_I, "semanticVersion"))
    end
  end

  def persisted?
    id.present?
  end
 
  # Access the owner short name (of the namespace)
  # 
  # @return [string] The owner's short name
  def owner
    return self.namespace.short_name
  end
  
  # Access the id for the owner (namespace)
  #
  # @return [string] The owner's id
  #def owner_id
  #  return self.namespace.uri.fragment
  #end
  
  # Obtain the scoping namespace
  # 
  # @return [IsoNamespace] the namespace object
  def scoping_namespace
    return self.namespace
  end
  
  # Get the next version
  #
  # @return [integer] The updated version
  def next_version
    return self.version + 1
  end
  
  # Get the next version
  #
  # @return [integer] The updated version
  def next_semantic_version
    temp = SemanticVersion.from_s self.semantic_version.to_s
    temp.increment_minor
    return temp
  end
  
  # A later version than specified?
  #
  # @param version [integer] The version to compare against
  # @return [boolean] True or False
  def later_version?(version)
    return self.version > version
  end
  
  # An earlier version than specified?
  #
  # @param version [integer] The version to compare against
  # @return [boolean] True or False
  def earlier_version?(version)
    return self.version < version
  end
  
  # Same version than specified?
  #
  # @param version [integer] The version to compare against
  # @return [boolean] True or False
  def same_version?(version)
    return self.version == version
  end
  
  #def first_version
  #  return C_FIRST_VERSION
  #end
  
  # Return the first version
  #
  # @return [integer] The first version
  def self.first_version
    return C_FIRST_VERSION
  end
  
  # Find if the object with identifier exists within the specified scope (namespace).
  #
  # @return [boolean] True if the item exists, False otherwise.
  def exists?
    result = false
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:ScopedIdentifier . \n" +
      "  ?a isoI:identifier \"#{self.identifier}\" . \n" +
      "  ?a isoI:hasScope #{self.namespace.uri.to_ref} . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      if uri != "" 
        result = true
      end
    end
    return result
  end

  # Find if the object with the identifier with a specified version exists within the specified scope (namespace).
  #
  # @return [boolean] True if the item exists, False otherwise.
  def version_exists?
    result = false
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:ScopedIdentifier . \n" +
      "  ?a isoI:identifier \"#{self.identifier}\" . \n" +
      "  ?a isoI:version #{self.version} . \n" +
      "  ?a isoI:hasScope #{self.namespace.uri.to_ref} . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      if uri != "" 
        result = true
      end
    end
    return result
  end

  # Find the latest version for a given identifier within the specified scope (namespace).
  #
  # @param identifier [string] The identifer being checked.
  # @param scope_id [string] The id of the scope namespace (IsoNamespace object).
  # @return [boolean] True if the item exists, False otherwise.
  def self.latest(identifier, scope_id)   
    result = false
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:ScopedIdentifier . \n" +
      "  ?a isoI:identifier \"#{identifier}\" . \n" +
      "  ?a isoI:version ?b . \n" +
      "  ?a isoI:hasScope :#{scope_id} . \n" +
      "} ORDER BY DESC(?b)"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      latest_version = ModelUtility.getValue('b', false, node)
      if latest_version != "" 
        #ConsoleLogger::log(C_CLASS_NAME,"latest","Latest: #{latest_version}")
        return latest_version.to_i
      end
    end
    return C_FIRST_VERSION
  end

  # Next Version. Obtain the next version for a given identifier within the specified scope (namespace).
  #
  # @param [String] identifier the identifer being checked.
  # @param [IsoNamespace] scope the scope namespace (IsoNamespace object).
  # @return [Integer] the next version.
  def self.next_version(identifier, scope)   
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:ScopedIdentifier . \n" +
      "  ?a isoI:identifier \"#{identifier}\" . \n" +
      "  ?a isoI:version ?b . \n" +
      "  ?a isoI:hasScope #{scope.uri.to_ref} . \n" +
      "} ORDER BY DESC(?b)"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    nodes = xmlDoc.xpath("//result")
    return C_FIRST_VERSION if nodes.empty?
    return ModelUtility.getValue('b', false, nodes.first).to_i + 1
  end

  # Find the item gievn the id
  #
  # @id [string] The id to be found
  # @return [object] The Scoped Identifier if found, nil otherwise
  def self.find(id)    
    object = self.new
    #ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b ?c ?d ?e ?f WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:identifier ?b . \n" +
      "  :" + id + " isoI:versionLabel ?c . \n" +
      "  :" + id + " isoI:version ?d . \n" +
      "  :" + id + " isoI:hasScope ?e . \n" +
      "  OPTIONAL { :" + id + " isoI:semanticVersion ?f . } \n" +  
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
      sv = ModelUtility.getValue('f', false, node)
      if iSet.length == 1 and vlSet.length == 1 and vSet.length == 1
        object.id = id
        object.identifier = iSet[0].text
        object.version = (vSet[0].text).to_i
        object.versionLabel = vlSet[0].text
        object.semantic_version = sv == "" ? SemanticVersion.new({}) : SemanticVersion.from_s(sv)
        object.namespace = IsoNamespace.find(Uri.new(uri: sSet[0].text))
      end
    end
    return object    
  end

  # Find all items
  #
  # @return [Array] An array of Scoped Identifier objects.
  def self.all    
    results = Array.new
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
        "{ \n" +
        "	 ?a rdf:type isoI:ScopedIdentifier . \n" +
        "  ?a isoI:identifier ?b . \n" +
        "	 ?a isoI:versionLabel ?c . \n" +
        "  ?a isoI:version ?d . \n" +
        "  ?a isoI:hasScope ?e . \n" +
        "  OPTIONAL { ?a isoI:semanticVersion ?f . } \n" +  
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
      sv = ModelUtility.getValue('f', false, node)
      if uriSet.length == 1 and vlSet.length == 1 and iSet.length == 1 and vSet.length == 1 and sSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = iSet[0].text
        object.version = (vSet[0].text).to_i
        object.versionLabel = vlSet[0].text
        object.semantic_version = sv == "" ? SemanticVersion.new({}) : sv
        object.namespace = IsoNamespace.find(Uri.new(uri: sSet[0].text))
        results << object
      end
    end    
    return results
  end

  # Find the set of unique identifiers for a given RDF Type
  #
  # @param rdfType [string] The RDF type to be searched for.
  # @param ns [string] The namespace within with the search is to take place.
  # @return [array] Each hash contains {identifier, label, owner id, owner short name} ordered by version (descending)
  def self.allIdentifier(rdfType, ns)
    results = Array.new
    check = Hash.new
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT DISTINCT ?d ?e ?f ?g WHERE \n" +
      "{\n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a isoT:hasIdentifier ?c . \n" +
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
        scope_namespace = IsoNamespace.find(Uri.new(uri: scope))
        key = scope_namespace.short_name + "_" + identifier
        if !check.has_key?(key)
          results << {:identifier => identifier, :label => label, :scope_id => scope_namespace.id, :owner => scope_namespace.short_name}
          check[key] = key
        end
      end
    end
    return results    
  end

  # Create the object in the triple store.
  #
  # @param identifier [String] the identifer being created
  # @param version [Integer] the version.
  # @param version_label [String] the version label
  # @param semantic_version [String] the semanctic version
  # @param scope_org [IsoNamespace] the owner organisation
  # @raise [Exceptions::CreateError] if any errors occur during the create
  # @return [IsoScopedIdentifier] The created object. Error count set if failed.
  def self.create(identifier, version, version_label, semantic_version, scope_org)
    semantic_version = SemanticVersion.from_s(semantic_version)
    object = IsoScopedIdentifier.from_data(identifier, version, version_label, semantic_version, scope_org)
    if object.valid?
      if !object.exists?
        update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "	 :#{object.id} rdf:type isoI:ScopedIdentifier . \n" +
          "	 :#{object.id} isoI:identifier \"#{object.identifier}\"^^xsd:string . \n" +
          "	 :#{object.id} isoI:version \"#{object.version}\"^^xsd:positiveInteger . \n" +
          "  :#{object.id} isoI:versionLabel \"#{object.versionLabel}\"^^xsd:string . \n" +
          "  :#{object.id} isoI:semanticVersion \"#{object.semantic_version}\"^^xsd:string . \n" +
          "	 :#{object.id} isoI:hasScope #{object.namespace.uri.to_ref} . \n" +
          "}"
        response = CRUD.update(update)
        if !response.success?
          ConsoleLogger.info(C_CLASS_NAME, "create", "Failed to create object.")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      else
        object.errors.add(:base, "The scoped identifier is already in use.")
      end
    end
    return object
  end

  # Update the object. Updates the version label and/or semantic version.
  #
  # @raise [Exceptions::UpdateError] if any errors occur during the update
  # @return [Null] no return. Errors, if any, in the class errors 
  def update(params)
    self.versionLabel = params[:versionLabel] if params[:versionLabel]
    self.semantic_version.increment_major if params[:semantic_version] == :major
    if valid?
      update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI"]) +
        "DELETE \n" +
        "{ \n" +
        " :#{self.id} isoI:versionLabel ?a . \n" +
        " :#{self.id} isoI:semanticVersion ?b . \n" +
        "} \n" +
        "INSERT \n" +
        "{ \n" +
        " :#{self.id} isoI:versionLabel \"#{self.versionLabel}\"^^xsd:string . \n" +
        " :#{self.id} isoI:semanticVersion \"#{self.semantic_version}\"^^xsd:string . \n" +
        "} \n" +
        "WHERE \n" +
        "{ \n" +
        " :#{self.id} isoI:versionLabel ?a . \n" +
        " OPTIONAL { :#{self.id} isoI:semanticVersion ?b . } \n" +
        "}"
      response = CRUD.update(update)
      if !response.success?
        ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
        raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
      end
    end
  end

  # Destroy the object
  #
  # @return null
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

  # Create the object from data. Will build the id for the object.
  #
  # @param identifier [String] The identifer being checked.
  # @param version [Integer] The version.
  # @param version_label [String] The version label.
  # @param semantic_version [SemanticVerson] The semantic version.
  # @param scope_org [object] The owner organisation (IsoNamespace object)
  # @return [object] The created object.
  def self.from_data(identifier, version, version_label, semantic_version, scope_org)
    object = self.new
    uri = UriV2.new({:namespace => @@base_namespace, :prefix => C_CID_PREFIX, :org_name => scope_org.short_name, :identifier => identifier, :version => version})
    object.id = uri.id
    object.version = version
    object.versionLabel = version_label
    object.identifier = identifier
    object.semantic_version = semantic_version
    object.namespace = scope_org
    return object
  end

  # Create the object from JSON
  #
  # @param [hash] The JSON hash object
  # @return [object] The scoped identifier object
  def self.from_json(json)
    object = self.new
    object.namespace = IsoNamespace.from_h(json[:namespace])
    object.id = json[:id]
    object.identifier = json[:identifier]
    object.versionLabel = json[:version_label]
    object.version = json[:version]
    object.semantic_version = SemanticVersion.from_s(json[:semantic_version])
    return object
  end

  # Return the object as JSON
  #
  # @return [hash] The JSON hash.
  def to_json
    json = 
    { 
      :id => self.id, 
      :identifier => self.identifier,
      :version_label => self.versionLabel,
      :version => self.version,
      :semantic_version => self.semantic_version.to_s,
      :namespace => self.namespace.to_h
    }
    return json
  end

  # Return the object as SPARQL
  #
  # @param sparql [object] The sparql object being built (to be added to)
  # @return [object] The URI of the object
  def to_sparql_v2(sparql)
    subject_uri = UriV2.new({id: self.id, namespace: @@base_namespace})
    subject = {uri: subject_uri}
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_I, :id => "identifier"}, {:literal => "#{self.identifier}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_ISO_I, :id => "ScopedIdentifier"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_I, :id => "version"}, {:literal => "#{self.version}", :primitive_type => "positiveInteger"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_I, :id => "versionLabel"}, {:literal => "#{self.versionLabel}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_I, :id => "semanticVersion"}, {:literal => "#{self.semantic_version}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_I, :id => "hasScope"}, {uri: self.namespace.uri})
    return subject_uri
  end

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    result = FieldValidation.valid_identifier?(:identifier, self.identifier, self) && 
      FieldValidation.valid_version?(:version, self.version, self) && 
      FieldValidation.valid_label?(:versionLabel, self.versionLabel, self)
    return result
  end

end