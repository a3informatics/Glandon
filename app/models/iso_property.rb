require "nokogiri"
require "uri"

class IsoProperty

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :namespace, :rdfType, :domain, :datatype, :label, :defintion
  validates_presence_of :id, :namespace, :rdfType, :domain, :datatype, :label, :defintion

  # Constants
  C_NS_PREFIX = "mdrCons"
  C_CID_PREFIX = "P"
  C_CLASS_NAME = "IsoProperty"
        
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
  
  def self.find(id, ns=nil)
    
    object = nil
    
    # Set the namespace
    useNs = ns || @@baseNs

    # Create the query
    query = UriManagement.buildNs(useNs, ["isoC"]) +
      "SELECT ?b ?c ?d ?e ?f WHERE \n" +
      "{ \n" +
        "  :" + id + " rdf:type ?b . \n" +
        "  :" + id + " rdfs:domain ?c . \n" +
        "  :" + id + " rdfs:range ?d . \n" +
        "  :" + id + " rdfs:label ?e . \n" +
        "  :" + id + " skos:definition ?f . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      rdfType = ModelUtility.getValue('b', false, node)
      domain = ModelUtility.getValue('c', false, node)
      range = ModelUtility.getValue('d', false, node)
      label = ModelUtility.getValue('e', false, node)
      defintion = ModelUtility.getValue('f', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      if name != ""
        object = self.new 
        object.id = ModelUtility::extractCid(uri[0].text)
        object.namespace = useNS
        object.rdfType = rdfType 
        object.domain = domain 
        object.datatype = range
        object.label = label
        object.defintion = defintion
      end
    end
    
    # Return
    return object
    
  end

  def self.all(ns=nil)
    
    results = Hash.new
    
    # Set the namespace
    useNs = ns || @@baseNs

    # Create the query
    query = UriManagement.buildNs(useNs, ["isoC"]) +
      "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
        "{ \n" +
        "	 ?a rdfs:subPropertyOf isoC:property . \n" +
        "  ?a rdf:type ?b . \n" +
        "  ?a rdfs:domain ?c . \n" +
        "  ?a rdfs:range ?d . \n" +
        "  ?a rdfs:label ?e . \n" +
        "  ?a skos:definition ?f . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      rdfType = ModelUtility.getValue('b', false, node)
      domain = ModelUtility.getValue('c', false, node)
      range = ModelUtility.getValue('d', false, node)
      label = ModelUtility.getValue('e', false, node)
      defintion = ModelUtility.getValue('f', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      if name != ""
        object = self.new 
        object.id = ModelUtility::extractCid(uri[0].text)
        object.namespace = useNS
        object.rdfType = rdfType 
        object.domain = domain 
        object.datatype = range
        object.label = label
        object.defintion = defintion
        results[object.id] = object
      end
    end
    return results
    
  end
  
  def self.create(params, ns=nil)
    
    object = self.new
    object.errors.clear

    # Set the namespace
    useNs = ns || @@baseNs

    # Check parameters
    if params_valid?(params, object)
      
      # Get the parameters
      rdfType = params[:rdfType]
      domain = params[:domain]
      datatype = params[:datatype]
      label = params[:label]
      definition = params[:defintion]
      
      # Create the id
      id = ModelUtility.buildCidIdentifier(C_CID_PREFIX, rdfType)
      
      # Create the id. Use the short name as the unique part.
      if !exists?(id, ns)

        # Create the query
        update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "	 :" + id + " rdf:type :" + rdfType " . \n" +
          "  :" + id + " rdfs:subPropertyOf isoC:property . \n" +
          "  :" + id + " rdfs:domain :" + domain + " . \n" +
          "  :" + id + " rdfs:range xsd:" + datatype + " . \n" +
          "  :" + id + " rdfs:label \"" + label + "\"^^xsd:string . \n" +
          "  :" + id + " skos:definition \"" + defintion + "\"^^xsd:string . \n" +
          "}"
    
        # Send the request, wait the resonse
        response = CRUD.update(update)

        # Response
        if response.success?
          object.id = item.id
          object.namespace = useNs
          object.rdfType = rdfType
          object.domain = domain
          object.label = label
          object.definition = definition
          object.datatype = datatype
          ConsoleLogger::log(C_CLASS_NAME,"create","Object created, id=" + id)
        else
          ConsoleLogger::log(C_CLASS_NAME,"create","Object not created!")
          object.errors.add(:base, "The property was not created in the database.")
          #object.assign_errors(data) if response.response_code == 422
        end
      
      else
        
        # Object exists
        object.errors.add(:base, "The property name entered is already in use.")

      end
    end

    return object
    
  end

  #def destroy
  #  
  #  ConsoleLogger::log(C_CLASS_NAME,"destroy","Id=" + self.id)
  #  
  #  # Create the query
  #  update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoC"]) +
  #    "DELETE \n" +
  #    "{\n" +
  #    "	 :" + self.id + " ?a ?b . \n" +
  #    "	 ?c isoC:ConceptSystemMemberConceptRelationship :" + self.id.to_s + " . \n" +
  #    "}\n" +
  #    "WHERE\n" + 
  #    "{\n" +
  #    "	 :" + self.id + " ?a ?b . \n" +
  #    "	 :" + self.id + " isoC:ConceptIncludingConceptSystemRelationship ?c . \n" +
  #    "}\n"
  #
  #  # Send the request, wait the resonse
  #  response = CRUD.update(update)
  #  
  #  # Process response
  #  if response.success?
  #    ConsoleLogger::log(C_CLASS_NAME,"destroy","Deleted")
  #  else
  #    ConsoleLogger::log(C_CLASS_NAME,"destroy","Error!")
  #  end
  #  
  #end
  
end