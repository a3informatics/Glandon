require "nokogiri"
require "uri"

class IsoDesignatableItem

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations

  attr_accessor :id, :namespace, :rdfType, :label, :identifier, :definition
  
  # Constants
  C_SCHEMA_PREFIX = "isoT"
  C_INSTANCE_PREFIX = "mdrItems"
  C_CLASS_NAME = "IsoDesignatableItem"
  
  # Base namespace 
  @@schemaNs = UriManagement.getNs(C_SCHEMA_PREFIX)
  @@instanceNs = UriManagement.getNs(C_INSTANCE_PREFIX)
  
  # Does the item exist. Cannot be used for child objects!
  def self.exists?(rdfType, identifier)
    
    ConsoleLogger::log(C_CLASS_NAME,"findExists?","*****ENTRY*****")
    result = false
    
    # Create the query
    query = UriManagement.buildNs(@@instanceNs, ["isoT"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a isoT:identifier \"" + identifier + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"create","Node=" + node.to_s)
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1
        result = true
        ConsoleLogger::log(C_CLASS_NAME,"exists?","Object exists!")        
      end
    
    end
    
    # Return
    return result

  end

  # Note: The id is the identifier for the enclosing managed object. 
  def self.find(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    
    # Initialise
    object = nil
    
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    ConsoleLogger::log(C_CLASS_NAME,"find","namespace=" + ns)
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoT"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  :" + id + " rdf:type ?a . \n" +
      "  :" + id + " rdfs:label ?b . \n" +
      "  :" + id + " isoT:identifier ?c . \n" +
      "  :" + id + " isoT:definition ?d . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      label = ModelUtility.getValue('b', false, node)
      identifier = ModelUtility.getValue('c', false, node)
      definition = ModelUtility.getValue('d', false, node)
      rdfType = ModelUtility.getValue('a', true, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","Label=" + label)
      if rdfType != ""
        object = self.new
        object.id = id
        object.namespace = ns
        object.label = label
        object.identifier = identifier
        object.definition = definition
        object.rdfType = rdfType
      end
    end
    
    # Return
    return object
    
  end

  def self.all(rdfType, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"all","*****Entry*****")
    
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "  ?a isoT:identifier ?c . \n" +
      "  ?a isoT:definition ?d . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('b', false, node)
      identifier = ModelUtility.getValue('c', false, node)
      definition = ModelUtility.getValue('d', false, node)
      if uri != ""
        object = self.new
        object.id = id
        object.namespace = ns
        object.label = label
        object.identifier = identifier
        object.definition = definition
        object.rdfType = rdfType
        results[object.id] = object
      end
    end
    
    # Return
    return results
    
  end

  def self.create(prefix, params, rdfType, schemaNs, instanceNs)
  
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, params[:identifier])
    object.namespace = instanceNs
    object.label = params[:label]
    object.definition = params[:definition]
    object.identifier = params[:identifier]
    object.rdfType = rdfType

    prefixSet = ["isoT"]
    prefixSet << UriManagement.getPrefix(schemaNs)
    update = UriManagement.buildNs(instanceNs, prefixSet) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + object.id + " rdf:type :" + object.rdfType + " . \n" +
      "  :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:identifier \"" + object.identifier + "\"^^xsd:string . \n" +
      "  :" + object.id + " isoT:definition \"" + object.definition + "\"^^xsd:string . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create","Success, id=" + object.id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end
    return object
  
  end

end