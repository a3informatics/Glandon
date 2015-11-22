require "nokogiri"
require "uri"

class Iso11179ConceptSystem

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :notation, :concepts, :classifications 
  validates_presence_of :id, :notation
  
  # Constants
  C_NS_PREFIX = "mdrSch"
  C_CID_PREFIX = "CS"
  C_CLASS_NAME = "Iso11179ConceptSystem"
        
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
        "	 :" + id + " rdf:type isoC:ConceptSystem . \n" +
        "	 :" + id + " isoC:notation ?a . \n" +
        "  OPTIONAL" +
        "  { \n" +
        "	   :" + id + " isoC:ConceptSystemMemberConceptRelationship ?b . \n" +
        "	   :" + id + " isoC:ConceptSystemClassificationRelationship ?c . \n" +
        "  } \n" +
        "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      nSet = node.xpath("binding[@name='a']/literal")
      cSet = node.xpath("binding[@name='b']/uri")
      clSet = node.xpath("binding[@name='c']/uri")
      if nSet.length == 1
        if object == nil
          object = self.new 
          object.id = id
          object.notation = nSet[0].text
          object.concepts = Hash.new
          object.classifications = Hash.new
          ConsoleLogger::log(C_CLASS_NAME,"find","Object=" + id)
        end
        if cSet.length == 1
          child_id = ModelUtility.extractCid(cSet[0].text)
          object.concepts[child_id]= child_id
          ConsoleLogger::log(C_CLASS_NAME,"find","Concept=" + child_id)
        end
        if clSet.length == 1
          child_id = ModelUtility.extractCid(clSet[0].text)
          object.classifications[child_id] = child_id
          ConsoleLogger::log(C_CLASS_NAME,"find","Classification=" + child_id)
        end
      end
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Hash.new
    object = nil
    
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
        "{ \n" +
        "	 ?a rdf:type isoC:ConceptSystem . \n" +
        "	 ?a isoC:notation ?b . \n" +
        "  OPTIONAL" +
        "  { \n" +
        "	   ?a isoC:ConceptSystemMemberConceptRelationship ?c . \n" +
        "	   ?a isoC:ConceptSystemClassificationRelationship ?d . \n" +
        "  } \n" +
        "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nSet = node.xpath("binding[@name='b']/literal")
      cSet = node.xpath("binding[@name='c']/uri")
      clSet = node.xpath("binding[@name='d']/uri")
      if uriSet.length == 1 && nSet.length == 1
        id = ModelUtility.extractCid(uriSet[0].text)
        if results.has_key?(id)
          object = results[id]
        else
          object = self.new 
          object.id = ModelUtility.extractCid(uriSet[0].text)
          object.notation = nSet[0].text
          object.concepts = Hash.new
          object.classifications = Hash.new
          results[object.id] = object
        end
        if cSet.length == 1
          child_id = ModelUtility.extractCid(cSet[0].text)
          object.concepts[child_id] = child_id
        end
        if clSet.length == 1
          child_id = ModelUtility.extractCid(clSet[0].text)
          object.classifications[child_id] = child_id
        end
      end
    end
    return results
  end

  def self.create(params)
    
    notation = params[:notation]
    id = ModelUtility.buildCid(C_CID_PREFIX, notation)
    ConsoleLogger::log(C_CLASS_NAME,"create","Id=" + id)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoC:ConceptSystem . \n" +
      "	 :" + id + " isoC:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.notation = notation
      ConsoleLogger::log(C_CLASS_NAME,"create","Success")
    else
      object = self.new
      object.assign_errors(data) if response.response_code == 422
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end
    return object
    
  end

  def update(classification, concept)
    
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + self.id + " isoC:ConceptSystemMemberConceptRelationship :" + concept.id.to_s + " . \n" +
      "	 :" + self.id + " isoC:ConceptSystemClassificationRelationship :" + classification.id.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      self.concepts[concept.id] = concept.id
      self.classifications[classification.id] = classification.id
      ConsoleLogger::log(C_CLASS_NAME,"update","Success")
    else
      self.assign_errors(data) if response.response_code == 422
      ConsoleLogger::log(C_CLASS_NAME,"update","Failed")
    end
    
  end

  def destroy
    
    ConsoleLogger::log(C_CLASS_NAME,"destroy","Id=" + self.id)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + self.id + " rdf:type isoC:ConceptSystem . \n" +
      "	 :" + self.id + " isoC:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "}"
    # Need to remove links and stuff here *****
      
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