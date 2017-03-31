class IsoConceptSystem::Node < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem::Node"
  C_CID_PREFIX = "CSN"
  C_RDF_TYPE = "ConceptSystemNode"
  C_SCHEMA_PREFIX = IsoConceptSystemGeneric::C_SCHEMA_PREFIX

  # Add a child object
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised
  def add(params)
    object = IsoConceptSystem::Node.from_json(params)
    if object.valid?
      sparql = object.to_sparql_v2
      sparql.default_namespace(object.namespace)
      create_child(object, sparql, C_SCHEMA_PREFIX, "hasMember")
    end
    return object
  end

  # Find system that is the ultimate parent of given an object.
  #
  # @param id [string] the id of the item 
  # @param namespace [string] the namespace of the item
  # @return [URI] The URI of the concept system
  def self.find_system(id, namespace)
    result = nil
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_C]) +
      "SELECT DISTINCT ?s ?o WHERE \n" +
      "{ \n" +
      "  ?s (isoC:hasMember)* :#{id} . \n" +      
      "  ?s rdf:type isoC:ConceptSystem . \n" +      
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    nodes = xmlDoc.xpath("//result")
    if nodes.length == 1
      uri = UriV2.new({uri: ModelUtility.getValue('s', true, nodes[0])})
    end
    return uri
  end

  # Find parent node of given an object.
  #
  # @param id [string] the id of the item 
  # @param namespace [string] the namespace of the item
  # @return [URI] The URI of the concept system
  def self.find_parent(id, namespace)
    uri = nil
    query = UriManagement.buildNs(namespace, [UriManagement::C_ISO_C]) +
      "SELECT DISTINCT ?s ?o WHERE \n" +
      "{ \n" +
      "  ?s isoC:hasMember :#{id} . \n" +      
      "  ?s rdf:type isoC:ConceptSystemNode . \n" +      
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    nodes = xmlDoc.xpath("//result")
    if nodes.length == 1
      uri = UriV2.new({uri: ModelUtility.getValue('s', true, nodes[0])})
    end
    return uri
  end

  # Destroy this object and links to it.
  #
  # @raise [DestroyError] If object not destroyed.
  # @return [Null]
  def destroy
    destroy_with_links
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = super(json, C_RDF_TYPE)
    return object
  end

  # Return the object as SPARQL
  #
  # @return [object] The URI of the object
  def to_sparql_v2
    sparql = super(C_CID_PREFIX)
    return sparql
  end

end