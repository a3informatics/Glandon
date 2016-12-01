class IsoConceptSystem < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem"
  C_CID_PREFIX = "CS"
  C_RDF_TYPE = "ConceptSystem"
  
  def self.all
    results = super(C_RDF_TYPE)
  end

  def self.create(params)
    object = IsoConceptSystem.from_json(params)
    if object.valid?
      sparql = object.to_sparql_v2
      sparql.default_namespace(object.namespace)
      response = CRUD.update(sparql.to_s)
      if !response.success?
        object.errors.add(:base, "The Concept System was not created in the database.")
      end
    end
    return object
  end

  def add(params)
    object = IsoConceptSystem::Node.from_json(params)
    if object.valid?
      sparql = object.to_sparql_v2
      sparql.triple({:uri => self.uri}, {:prefix => UriManagement::C_ISO_C, :id => "hasMember"}, {:uri => object.uri})
      sparql.default_namespace(object.namespace)
      response = CRUD.update(sparql.to_s)
      ConsoleLogger.info(C_CLASS_NAME, "add", "SPARQl=#{sparql.to_s}")
      if !response.success?
        object.errors.add(:base, "The Concept System Node was not created in the database.")
      end
    end
    return object
  end

  def destroy
    update = UriManagement.buildNs(self.namespace, [C_SCHEMA_PREFIX]) +
      "DELETE \n" +
      "{\n" +
      "  :#{self.id} ?p ?o . \n" +  
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " ?p ?o . \n" +  
      "}\n"
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  def self.from_json(json)
    object = super(json, C_RDF_TYPE)
    return object
  end

  def to_sparql_v2
    sparql = super(C_CID_PREFIX)
    return sparql
  end

end