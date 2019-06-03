class IsoConceptSystem::Node < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem::Node"
  C_CID_PREFIX = "CSN"
  C_RDF_TYPE = "ConceptSystemNode"
  C_SCHEMA_PREFIX = IsoConceptSystemGeneric::C_SCHEMA_PREFIX

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

end