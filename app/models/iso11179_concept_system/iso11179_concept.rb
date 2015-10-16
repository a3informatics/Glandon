require "nokogiri"
require "uri"

class Iso11179ConceptSystem::Iso11179Concept

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :classification_id, :concepts, :conceptSystem_id
  validates_presence_of :id, :classification_id, :concepts, :parent_id
  
  # Constants
  C_NS_PREFIX = "mdrSch"
  C_CID_PREFIX = "C"
  C_CLASS_NAME = "iso11179Concept"
        
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def baseNs
    return @@baseNs 
  end
  
  def self.find(id)
    
    object = nil
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "SELECT ?a ?b ?g WHERE \n" +
        "{ \n" +
        "	 :" + id + " rdf:type isoC:Concept . \n" +
        "	 :" + id + " isoC:ConceptClassifiedItemRelationship ?a . \n" +
        "	 :" + id + " isoC:ConceptIncludingConceptSystemRelationship ?b . \n" +
        #"	 :" + id + " isoC:ConceptLinkEndRelationship ?c . \n" +
        #"	 ?c isoC:ConceptLinkEndRelationship ?d . \n" +
        #"	 ?d isoC:LinkEndLinkRelationship ?e . \n" +
        #"	 ?e isoC:LinkLinkEndRelationship ?f . \n" +
        #"	 ?f isoC:LinkEndConceptRelationship ?g . \n" +
        "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      clSet = node.xpath("binding[@name='a']/uri")
      csSet = node.xpath("binding[@name='b']/uri")
      #cSet = node.xpath("binding[@name='g']/uri")
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      if clSet.length == 1 && csSet.length == 1
        if object == nil
          object = self.new 
          object.id = id
          ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id)
          object.classification_id = ModelUtility.extractCid(clSet[0].text)
          object.conceptSystem_id = ModelUtility.extractCid(csSet[0].text)
          object.concepts = Hash.new
        end
        #if cSet.length == 1 
        #  child = self.new
        #  child.id = ModelUtility.extractCid(cSet[0].text)
        #  object.concepts.push[child.id]= child
        #end
      end
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "SELECT ?a ?b ?g ?h WHERE \n" +
        "{ \n" +
        "	 ?h rdf:type isoC:Concept . \n" +
        "	 ?h isoC:ConceptClassifiedItemRelationship ?a . \n" +
        "	 ?h isoC:ConceptIncludingConceptSystemRelationship ?b . \n" +
        "	 ?h isoC:ConceptLinkEndRelationship ?c . \n" +
        "	 ?c isoC:ConceptLinkEndRelationship ?d . \n" +
        "	 ?d isoC:LinkEndLinkRelationship ?e . \n" +
        "	 ?e isoC:LinkLinkEndRelationship ?f . \n" +
        "	 ?f isoC:LinkEndConceptRelationship ?g . \n" +
        "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='h']/uri")
      clSet = node.xpath("binding[@name='a']/uri")
      csSet = node.xpath("binding[@name='b']/uri")
      cSet = node.xpath("binding[@name='g']/uri")
      if uriSet.length == 1 && clSet.length == 1 && csSet.length == 1
        id = ModelUtility.extractCid(uriSet[0].text)
        if results.has_key?(id)
          object = results[id]
        else
          object = self.new 
          object.id = ModelUtility.extractCid(uriSet[0].text)
          object.classification_id = ModelUtility.extractCid(clSet[0].text)
          object.conceptSystem_id = ModelUtility.extractCid(csSet[0].text)
          object.concepts = Hash.new
          results[object.id] = object
        end
        if cSet.length == 1 
          child = self.new
          child.id = ModelUtility.extractCid(oSet[0].text)
          object.concepts.push[child.id]= child
        end
      end
    end
    return results
  end
  
  def self.create(params)
    
    # Set the idea
    id = ModelUtility.buildCidTime(C_CID_PREFIX)
    ConsoleLogger::log(C_CLASS_NAME,"create","Id=" + id)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoC:Concept . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.concepts = Hash.new
      ConsoleLogger::log(C_CLASS_NAME,"create","Success")
    else
      object = self.new
      object.assign_errors(data) if response.response_code == 422
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end
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