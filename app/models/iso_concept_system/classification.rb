class IsoConceptSystem::Classification < IsoConcept
  
  attr_accessor :links
  validates_presence_of :links
  
  # Constants
  C_SCHEMA_PREFIX = "isoC"
  C_INSTANCE_PREFIX = "mdrSch"
  C_CLASS_NAME = "IsoConceptSystem::Classification"
  C_CID_PREFIX = "CSC"
  C_RDF_TYPE = "Classification"

  # Base namespace 
  C_SCHEMA_NS
 = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    
    object = super(id, ns)
    object.links = IsoLinkInstance::Node.findForConcept(object.links, ns)
    return object  
    
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS
)
  end

  def self.create(params)
  
    object = createOtherItem(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS
, C_INSTANCE_NS)
    return object

  end

  def update(conceptSystem, concept)
    
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + self.id + " isoC:inScheme :" + conceptSystem.id.to_s + " . \n" +
      "	 :" + self.id + " isoC:classifiedAs :" + concept.id.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      self.conceptSystem_id = conceptSystem.id
      self.concept_id = concept.id
      ConsoleLogger::log(C_CLASS_NAME,"create","Success")
    else
      object.assign_errors(data) if response.response_code == 422
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end
    
  end

  def destroy
    
    ConsoleLogger::log(C_CLASS_NAME,"destroy","Id=" + self.id)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "DELETE \n" +
      "{\n" +
      "	 :" + self.id + " ?a ?b . \n" +
      "	 ?c isoC:ConceptSystemClassificationRelationship :" + self.id.to_s + " . \n" +
      "	 ?d isoC:ConceptClassifiedItemRelationship :" + self.id.to_s + " . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "	 :" + self.id + " ?a ?b . \n" +
      "	 :" + self.id + " isoC:ClassificationSchemeRelationship ?c . \n" +
      "	 :" + self.id + " isoC:ClassificationClassifierRelationship ?d . \n" +
      "}\n" 

    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Process response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Deleted")
    else
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Error!")
    end

  end
  
end