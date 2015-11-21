require "uri"

class BiomedicalConceptTemplate
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :properties, :namespace
  validates_presence_of :id, :managedItem, :properties, :namespace
  
  # Constants
  C_CLASS_NAME = "BiomedicalConceptTemplate"
  C_NS_PREFIX = "mdrBcts"
  C_CID_PREFIX = "BCT"
  
  # BC object
  #
  # object: id, scopeId, identifier, version, namespace, name, properties where properties is
  # properties [:cid => {:id, :alias, :datatype}]
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def version
    return self.managedItem.version
  end

  def versionLabel
    return self.managedItem.versionLabel
  end

  def identifier
    return self.managedItem.identifier
  end

  def label
    return self.managedItem.label
  end

  def owner
    return self.managedItem.owner
  end

  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    return @baseNs
  end
  
  def self.find(id, templateNamespace)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = nil
    query = UriManagement.buildNs(templateNamespace, ["cbc", "mdrItems", "isoI"]) +
      "SELECT ?bcDtNode ?bcPropertyNode ?datatype ?propertyAlias ?simple WHERE\n" + 
      "{ \n" + 
      "  :" + id + " (cbc:hasItem | cbc:hasDatatype )%2B ?bcDtNode .\n" + 
      "  OPTIONAL {\n" + 
      "    ?bcDtNode cbc:hasDatatypeRef ?datatype . \n" + 
      "    ?bcDtNode (cbc:hasProperty | cbc:hasComplexDatatype )%2B ?bcPropertyNode . \n" + 
      "    OPTIONAL { \n" + 
      "      ?bcPropertyNode cbc:alias ?propertyAlias . \n" +
      "      ?bcPropertyNode cbc:hasSimpleDatatype ?simple . \n" +
      "    }\n" + 
      "  }\n" + 
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      dtNodeURI = ModelUtility.getValue("bcDtNode", true, node)
      simpleURI = ModelUtility.getValue("simple", true, node)
      if dtNodeURI != "" && simpleURI != ""
        #ConsoleLogger::log(C_CLASS_NAME,"find","Found")
        if object != nil
          properties = object.properties          
        else
          object = self.new 
          properties = Hash.new
          object.properties = properties
          object.id = id
          object.namespace = templateNamespace
          object.managedItem = ManagedItem.find(id, templateNamespace)
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
        propertyUri = ModelUtility.getValue("bcPropertyNode", true, node)
        propertyCid = ModelUtility.extractCid(propertyUri)
        aliasName = ModelUtility.getValue("propertyAlias", false, node)
        dt = ModelUtility.getValue("datatype", true, node)
        #ConsoleLogger::log(C_CLASS_NAME,"find","Property URI=" + propertyUri)
        #ConsoleLogger::log(C_CLASS_NAME,"find","Property Alias=" + aliasName)
        if properties.has_key?(propertyCid)
          property = properties[propertyCid]
        else
          property = Hash.new
        end  
        properties[propertyCid] = property
        property[:Alias] = aliasName
        property[:Datatype] = getDatatype(dt)
      end
    end
    return object  
    
  end

  def self.all()
    
    ConsoleLogger::log(C_CLASS_NAME,"all","*****ENTRY*****")
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["cbc"]) +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type cbc:BiomedicalConceptTemplate . \n" +
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue("a", true, node)
      ConsoleLogger::log(C_CLASS_NAME,"all","URI=" + uri)
      if uri != ""
        id = ModelUtility.extractCid(uri)
        namespace = ModelUtility.extractNs(uri)
        object = self.new 
        object.id = id
        object.namespace = namespace
        object.managedItem = ManagedItem.find(id, namespace)
        if ManagedItem != nil
          object.properties = Hash.new
          ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + id)
          results[id] = object
        else
          ConsoleLogger::log(C_CLASS_NAME,"all","Object not created!" + id)
          object = nil
        end
      end
    end
    return results  
    
  end

  def self.create(params)
    object = nil
    return object
  end

  def update
    return nil
  end

  def destroy
  end

  def to_ttl()

    ConsoleLogger::log(C_CLASS_NAME,"to_ttl","*****Entry*****")
    results = ""
    query = UriManagement.buildNs(self.namespace, ["cbc"]) +
      "CONSTRUCT \n" +
      "{ \n" + 
      "  ?a ?b ?c .\n" + 
      "  ?d ?e ?f .\n" + 
      "  ?g ?h ?i .\n" + 
      "  ?j ?k ?l .\n" + 
      "  ?v ?w ?x .\n" +  
      "  ?m ?n ?o .\n" + 
      "  ?p ?q ?r .\n" + 
      "  ?s ?t ?u .\n" +
      "}\n" + 
      "WHERE \n" +
      "{\n" + 
      "  :" + self.id + " rdf:type cbc:BiomedicalConceptTemplate .\n" + 
      "  ?a rdf:type cbc:BiomedicalConceptTemplate .\n" + 
      "  ?a ?b ?c .\n" + 
      "  ?a cbc:hasItem ?d .\n" + 
      "  ?d ?e ?f .\n" + 
      "  ?d cbc:hasDatatype ?g .\n" + 
      "  ?g ?h ?i .\n" + 
      "  ?g cbc:hasProperty ?j .\n" + 
      "  ?j ?k ?l .\n" +
      "  OPTIONAL\n" +
      "  {\n" + 
      "    ?j cbc:hasComplexDatatype ?m . \n" + 
      "    ?m ?n ?o .\n" + 
      "    ?m cbc:hasProperty ?p .\n" + 
      "    ?p ?q ?r . \n" +
      "    ?p cbc:hasSimpleDatatype ?s .\n" + 
      "    ?s ?t ?u . \n" + 
      "  }\n" + 
      "  OPTIONAL\n" +
      "  {\n" + 
      "    ?j cbc:hasSimpleDatatype ?v .\n" + 
      "    ?v ?w ?x .\n" +  
      "  }\n" + 
      # "  VALUES (?a) {(\"" + self.id + "\")}\n" + 
      "}\n" 

    # Send the request, wait the resonse
    response = CRUD.query(query, CRUD.TTL)
    if response.success?
      return response.body
    else
      return ""
    end 

  end

private

  def self.getDatatype (text)
    result = ""
      parts = text.split("-")
      if parts.size == 2
        if parts[1] == "CD"
          result = "CL"
        elsif parts[1] == "PQR"
          result = "F"
        else
          result = ""
        end
      else
        result = ""
      end
    ConsoleLogger::log(C_CLASS_NAME,"getDatatype","Text=" + text + ", Result=" + result)
    return result 
  end
end
