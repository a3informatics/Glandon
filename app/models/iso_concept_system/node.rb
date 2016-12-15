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