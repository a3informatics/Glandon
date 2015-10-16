require "nokogiri"
require "uri"

class Iso11179ConceptSystem::Iso11179Classification

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :label, :conceptSystem_id, :concept_id
  validates_presence_of :id, :label
  
  # Constants
  C_NS_PREFIX = "mdrSch"
  C_CID_PREFIX = "CL"
  C_CLASS_NAME = "iso11179Classification"
        
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
      "SELECT ?a ?b ?c WHERE \n" +
        "{ \n" +
        "	 :" + id + " rdf:type isoC:Classification . \n" +
        "	 :" + id + " isoC:label ?a . \n" +
        "  OPTIONAL" +
        "  { \n" +
        "	   :" + id + " isoC:ClassificationSchemeRelationship ?b . \n" +
        "	   :" + id + " isoC:ClassificationClassifierRelationship ?c . \n" +
        "  } \n" +
        "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      lSet = node.xpath("binding[@name='a']/literal")
      csSet = node.xpath("binding[@name='b']/uri")
      cSet = node.xpath("binding[@name='c']/uri")
      if lSet.length == 1
        object = self.new 
        object.id = id
        object.label = lSet[0].text
        ConsoleLogger::log(C_CLASS_NAME,"find","Object Id=" + id)
        if csSet.length == 1
          object.conceptSystem_id = ModelUtility.extractCid(csSet[0].text)
        else
          object.conceptSystem_id = nil
        end
        if cSet.length == 1
          object.concept_id = ModelUtility.extractCid(cSet[0].text)
        else
          object.concept_id = nil
        end
      end
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
        "{ \n" +
        "	 ?a rdf:type isoC:Classification . \n" +
        "	 ?a isoC:label ?b . \n" +
        "  OPTIONAL" +
        "  { \n" +
        "	   ?a isoC:ClassificationSchemeRelationship ?c . \n" +
        "	   ?a isoC:ClassificationClassifierRelationship ?d . \n" +
        "  } \n" +
        "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      lSet = node.xpath("binding[@name='b']/literal")
      csSet = node.xpath("binding[@name='c']/uri")
      cSet = node.xpath("binding[@name='d']/uri")
      if uriSet.length == 1 && lSet.length == 1
        id = ModelUtility.extractCid(uriSet[0].text)
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.label = lSet[0].text
        if csSet.length == 1
          object.conceptSystem_id = ModelUtility.extractCid(cdSet[0].text)
        else
          object.conceptSystem_id = nil
        end
        if cSet.length == 1
          object.concept_id = ModelUtility.extractCid(cSet[0].text)
        else
          object.concept_id = nil
        end
        results[object.id] = object
      end
    end
    return results
  end
  
  def self.create(params)
  
    label = params[:label]
    id = ModelUtility.buildCid(C_CID_PREFIX, label)
    ConsoleLogger::log(C_CLASS_NAME,"create","Id=" + id)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoC:Classification . \n" +
      "	 :" + id + " isoC:label \"" + label.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.label = label
      object.concept_id = nil
      object.conceptSystem_id = nil
      ConsoleLogger::log(C_CLASS_NAME,"create","Success")
    else
      object = self.new
      object.assign_errors(data) if response.response_code == 422
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end
    return object
    
  end

  def update(conceptSystem, concept)
    
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + self.id + " isoC:ClassificationSchemeRelationship :" + conceptSystem.id.to_s + " . \n" +
      "	 :" + self.id + " isoC:ClassificationClassifierRelationship :" + concept.id.to_s + " . \n" +
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