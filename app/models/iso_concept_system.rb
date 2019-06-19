class IsoConceptSystem < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem"
  C_CID_PREFIX = "CS"
  C_RDF_TYPE = "ConceptSystem"
  C_SCHEMA_PREFIX = IsoConceptSystemGeneric::C_SCHEMA_PREFIX
  
  # Create an object from params
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised. May contain errors
  def self.create(params)
    object = IsoConceptSystem.from_json(params)
    if object.valid?
      sparql = object.to_sparql_v2
      sparql.default_namespace(object.namespace)
      object.create(sparql)
    end
    return object
  end

  # Root. Get the root node or create if not present
  #
  # @raise [CreateError] If object not created.
  # @return [Object] The new object created if no exception raised
  def self.root
    cs_set = IsoConceptSystem.all
    result = cs_set.empty? ? IsoConceptSystem.create(label: "Tags", description: "Root node for all tags") : IsoConceptSystem.find(cs_set.first.id, cs_set.first.namespace)
    Errors.application_error(C_CLASS_NAME, __method__.to_s, "Errors creating the tag root node. #{result.errors.full_messages.to_sentence}") if result.errors.any?
    result
  end

end