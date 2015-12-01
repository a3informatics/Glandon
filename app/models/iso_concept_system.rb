require "nokogiri"
require "uri"

class IsoConceptSystem

  include CRUD
  include ModelUtility
  include UriManagement
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :namespace, :identifier, :label, :notation, :nodes
  validates_presence_of :id, :namespace, :identifier, :label, :notation, :nodes

  # Constants
  C_NS_PREFIX = "mdrSch"
  C_CID_PREFIX = "CS"
  C_CLASS_NAME = "IsoConceptSystem"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)

  def persisted?
    id.present?
  end

  def initialize()
    self.notation = ""
  end

  def baseNs    
    return @@baseNs     
  end
  
  def self.exists?(identifier)
    
    ConsoleLogger::log(C_CLASS_NAME,"exists?","*****ENTRY*****")
    result = false
    
    # Create the query
    query = UriManagement.buildNs(@@baseNs, ["isoC"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
        "?a rdf:type isoC:ConceptSystem . \n" +
        "?a isoC:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"create","Node=" + node.to_s)
      uri = ModelUtility.getValue('a', true, node)
      if uri != ""
        result = true
        ConsoleLogger::log(C_CLASS_NAME,"exists?","Object exists!")        
      end
    
    end
    
    # Return
    return result
    
  end

  def self.find(id)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id)
    object = nil
    
    # Create the query
    query = UriManagement.buildNs(@@baseNs, ["isoC"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  :" + id.to_s + " rdf:type isoC:ConceptSystem . \n" +
      "  :" + id.to_s + " isoC:identifier ?a . \n" +
      "  :" + id.to_s + " isoC:notation ?b . \n" +
      "  :" + id.to_s + " rdfs:label ?c . \n" +
      "  OPTIONAL { \n " + 
      "     :" + id.to_s + " isoC:hasMember ?d . \n" +
      "  }" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node.to_s)
      identifier = ModelUtility.getValue('a', false, node)
      notation = ModelUtility.getValue('b', false, node)
      label = ModelUtility.getValue('c', false, node)
      member = ModelUtility.getValue('d', true, node)
      if notation != ""
        if object == nil
          object = self.new 
          object.id = id
          object.namespace = @@baseNs 
          object.identifier = identifier
          object.notation = notation
          object.label = label
          object.nodes = Hash.new
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
        if member != ""
          id = ModelUtility.extractCid(member)
          node = IsoConceptSystem::Node.find(id, @@baseNs)
          object.nodes[node.id] = node
        end
      end
    
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(@@baseNs, ["isoC"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  ?a rdf:type isoC:ConceptSystem . \n" +
      "  ?a rdfs:label ?d . \n" +
      "  ?a isoC:identifier ?b . \n" +
      "  ?a isoC:notation ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"all","Node=" + node.to_s)
      uri = ModelUtility.getValue('a', true, node)
      identifier = ModelUtility.getValue('b', false, node)
      notation = ModelUtility.getValue('c', false, node)
      label = ModelUtility.getValue('d', false, node)
      if uri != ""
        object = self.new 
        object.id = ModelUtility.extractCid(uri)
        object.namespace = @@baseNs 
        object.identifier = identifier
        object.notation = notation
        object.label = label
        ConsoleLogger::log(C_CLASS_NAME,"all","Created object=" + object.id)
        results[object.id] = object
      end
    end
    
    # Return
    return results
    
  end

  def self.create(params)
    
    # Create the object
    object = self.new 
    object.errors.clear

    # Check parameters
    if params_valid?(params, self)

      notation = params[:notation]
      identifier = params[:identifier]
      label = params[:label]
      if !exists?(identifier)
        id = ModelUtility.buildCidIdentifier(C_CID_PREFIX, identifier)
        ConsoleLogger::log(C_CLASS_NAME,"create","Id=" + id)
        
        # Create the query
        update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "  :" + id + " rdf:type isoC:ConceptSystem . \n" +
          "  :" + id + " rdfs:label \"" + label.to_s + "\"^^xsd:string . \n" +
          "  :" + id + " isoC:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
          "  :" + id + " isoC:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)
        
        # Response
        if response.success?
          object = self.new
          object.id = id
          object.label = label
          object.notation = notation
          object.identifier = identifier
          ConsoleLogger::log(C_CLASS_NAME,"create","Success")
        else
          object = self.new
          object.errors.add(:base, "The concept system was not created in the database.")
          ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
        end
      end
    end

    return object
    
  end

  def add(node)
    ConsoleLogger::log(C_CLASS_NAME,"add","*****Entry*****")
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + self.id + " isoC:hasMember :" + node.id.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"add","Success")
    else
      ConsoleLogger::log(C_CLASS_NAME,"add","Failed")
    end
    
  end

  def update(classification, concept)
    
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + self.id + " isoC:ConceptSystemMemberConceptRelationship :" + concept.id.to_s + " . \n" +
      "  :" + self.id + " isoC:ConceptSystemClassificationRelationship :" + classification.id.to_s + " . \n" +
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
      "  :" + self.id + " rdf:type isoC:ConceptSystem . \n" +
      "  :" + self.id + " isoC:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
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
   
private

  def self.params_valid?(params, object)
    
    result1 = ModelUtility::validIdentifier?(params[:identifier], object)
    result2 = ModelUtility::validFreeText?(:notation, params[:notation], object)
    return result1 && result2

  end

end