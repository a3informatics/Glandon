class IsoConceptSystem::Node < IsoDesignatableItem
  
  attr_accessor :nodes
  validates_presence_of :nodes
  
  # Constants
  C_SCHEMA_PREFIX = "isoC"
  C_INSTANCE_PREFIX = "mdrSch"
  C_CLASS_NAME = "IsoConceptSystem::Node"
  C_CID_PREFIX = "CSN"
  C_RDF_TYPE = "Concept"

  # Base namespace 
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  def self.find(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY******")
    
    # Get the main node
    object = super(id, ns)

    # Get any links
    query = UriManagement.buildNs(C_INSTANCE_NS, ["isoC"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  :" + id.to_s + " isoC:hasMember ?a . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node.to_s)
      member = ModelUtility.getValue('a', true, node)
      if member != ""
        ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node.to_s)
        node = find(ModelUtility.extractCid(member), @@baseNs)
        object.nodes[node.id] = node
      end
    
    end
    return object  
    
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS
)
  end

  def self.create(params)
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    object = super(C_CID_PREFIX, params, C_RDF_TYPE, C_SCHEMA_NS
, C_INSTANCE_NS)
    return object

  end

  def update(conceptSystem, classification)
    
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + self.id + " isoC:ConceptClassifiedItemRelationship :" + classification.id.to_s + " . \n" +
      "	 :" + self.id + " isoC:ConceptIncludingConceptSystemRelationship :" + conceptSystem.id.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      self.conceptSystem_id = conceptSystem.id
      self.classification_id = classification.id
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
      "	 ?c isoC:ConceptSystemMemberConceptRelationship :" + self.id.to_s + " . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "	 :" + self.id + " ?a ?b . \n" +
      "	 :" + self.id + " isoC:ConceptIncludingConceptSystemRelationship ?c . \n" +
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