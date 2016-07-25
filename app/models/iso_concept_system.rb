class IsoConceptSystem < IsoConceptSystemGeneric

  # Constants
  C_CLASS_NAME = "IsoConceptSystem"
  C_CID_PREFIX = "CS"
  C_RDF_TYPE = "ConceptSystem"
  
  def self.all
    results = super(C_RDF_TYPE)
  end

  def self.create(params)
    # Create blank object for the errors
    object = self.new
    object.errors.clear
    # Set owner ship
    if params_valid?(params, object) then
      # Build a full object. Special case, fill in the identifier, base on domain prefix.
      object = IsoConceptSystem.from_json(params)
      sparql = object.to_sparql
      sparql.add_default_namespace(object.namespace)
      # Send to database
      ConsoleLogger::log(C_CLASS_NAME,"create","Object=#{sparql}")
      response = CRUD.update(sparql.to_s)
      if !response.success?
        object.errors.add(:base, "The Concept System was not created in the database.")
      end
    end
    return object
  end

  def add(params)
    object = IsoConceptSystem::Node.from_json(params)
    sparql = object.to_sparql
    sparql.triple("", self.id, UriManagement::C_ISO_C, "hasMember", "", "#{object.id}")
    sparql.add_default_namespace(object.namespace)
    # Send the request, wait the resonse
    ConsoleLogger::log(C_CLASS_NAME,"add","Object=#{sparql}")
      response = CRUD.update(sparql.to_s)
    # Response
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"add","Success")
    end
  end

  def destroy
    # Create the query
    update = UriManagement.buildNs(self.namespace, [C_SCHEMA_PREFIX]) +
      "DELETE \n" +
      "{\n" +
      "  :#{self.id} ?p ?o . \n" +  
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " ?p ?o . \n" +  
      "}\n"
    # Send the request, wait the resonse
    ConsoleLogger::log(C_CLASS_NAME,"destroy","Update=#{update}")
    response = CRUD.update(update)
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  def self.from_json(json)
    object = super(json, C_RDF_TYPE)
    return object
  end

  def to_sparql
    sparql = super(C_CID_PREFIX)
    return sparql
  end

end