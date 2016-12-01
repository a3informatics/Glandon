class IsoConceptSystem::Node < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem::Node"
  C_CID_PREFIX = "CSN"
  C_RDF_TYPE = "ConceptSystemNode"
  
  def self.create(params)
    object = IsoConceptSystem::Node.from_json(params)
    if object.valid? 
      sparql = object.to_sparql_v2
      sparql.default_namespace(object.namespace)
      response = CRUD.update(sparql.to_s)
      if !response.success?
        object.errors.add(:base, "The Concept System Node was not created in the database.")
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
      "  ?s #{C_SCHEMA_PREFIX}:hasMember :#{self.id} . \n" +  
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " ?p ?o . \n" +  
      "  ?s #{C_SCHEMA_PREFIX}:hasMember :#{self.id} . \n" +  
      "}\n"
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::info(C_CLASS_NAME,"destroy", "Failed to destroy object.")
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