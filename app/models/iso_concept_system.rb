class IsoConceptSystem < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem"
  C_CID_PREFIX = "CS"
  C_RDF_TYPE = "ConceptSystem"
  C_SCHEMA_PREFIX = IsoConceptSystemGeneric::C_SCHEMA_PREFIX
  
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

end