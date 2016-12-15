class IsoConceptSystem < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem"
  C_CID_PREFIX = "CS"
  C_RDF_TYPE = "ConceptSystem"
  C_SCHEMA_PREFIX = IsoConceptSystemGeneric::C_SCHEMA_PREFIX
  
  # Find all concepts of a given type within specified namespace.
  #
  # @return [array] Array of objects
  def self.all
    results = super(C_RDF_TYPE)
  end

  # Create an object from params
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised
  def self.create(params)
    object = IsoConceptSystem.from_json(params)
    if object.valid?
      sparql = object.to_sparql_v2
      sparql.default_namespace(object.namespace)
      object.create(sparql)
    end
    return object
  end

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

  # Destroy this object
  #
  # @raise [DestroyError] If object not destroyed.
  # @return [Null]
  def destroy
    super
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