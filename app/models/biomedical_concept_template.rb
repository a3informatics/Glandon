require "uri"

class BiomedicalConceptTemplate < IsoManaged
  
  attr_accessor :items
  validates_presence_of :items
  
  # Constants
  C_SCHEMA_PREFIX = "cbc"
  C_INSTANCE_PREFIX = "mdrBcts"
  C_CLASS_NAME = "BiomedicalConceptTemplate"
  C_CID_PREFIX = "BCT"
  C_RDF_TYPE = "BiomedicalConceptTemplate"
  C_SCHEMA_NS = UriManagement.getNs(C_SCHEMA_PREFIX)
  C_INSTANCE_NS = UriManagement.getNs(C_INSTANCE_PREFIX)

  
  # BC object
  #
  # object: id, scopeId, identifier, version, namespace, name, items where items is
  # items [:cid => {:id, :alias, :datatype}]
  
  def self.find(id, ns)
    ConsoleLogger::log(C_CLASS_NAME,"find","*****ENTRY*****")
    object = super(id, ns)
    query = UriManagement.buildNs(ns, ["cbc", "mdrItems", "isoI"]) +
      "SELECT ?bcDtNode ?bcPropertyNode ?datatype ?propertyAlias ?simple WHERE\n" + 
      "{ \n" + 
      "  :" + id + " (cbc:hasItem | cbc:hasDatatype )%2B ?bcDtNode .\n" + 
      "  OPTIONAL {\n" + 
      "    ?bcDtNode cbc:hasDatatypeRef ?datatype . \n" + 
      "    ?bcDtNode (cbc:hasProperty | cbc:hasComplexDatatype )%2B ?bcPropertyNode . \n" + 
      "    OPTIONAL { \n" + 
      "      ?bcPropertyNode cbc:alias ?propertyAlias . \n" +
      "      ?bcPropertyNode cbc:hasValue ?simple . \n" +
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
        if object.items != nil
          items = object.items          
        else
          items = Hash.new
          object.items = items
        end
        itemUri = ModelUtility.getValue("bcPropertyNode", true, node)
        itemCid = ModelUtility.extractCid(itemUri)
        aliasName = ModelUtility.getValue("propertyAlias", false, node)
        dt = ModelUtility.getValue("datatype", true, node)
        #ConsoleLogger::log(C_CLASS_NAME,"find","Property URI=" + propertyUri)
        #ConsoleLogger::log(C_CLASS_NAME,"find","Property Alias=" + aliasName)
        if items.has_key?(itemCid)
          item = items[itemCid]
        else
          item = Hash.new
        end  
        items[itemCid] = item
        item[:Alias] = aliasName
        item[:Datatype] = getDatatype(dt)
      end
    end
    return object  
    
  end

  def self.all
    super(C_RDF_TYPE, C_SCHEMA_NS)
  end

  def self.unique
    ConsoleLogger::log(C_CLASS_NAME,"unique","ns=" + C_SCHEMA_NS)
    results = super(C_RDF_TYPE, C_SCHEMA_NS)
    return results
  end

  def self.history(identifier)
    results = super(C_RDF_TYPE, identifier, C_SCHEMA_NS)
    return results
  end

  def to_ttl()

    ConsoleLogger::log(C_CLASS_NAME,"to_ttl","*****Entry*****")
    results = ""
    query = UriManagement.buildNs(self.namespace, ["cbc","isoI"]) +
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
      "    ?p cbc:hasValue ?s .\n" + 
      "    ?s ?t ?u . \n" + 
      "  }\n" + 
      "  OPTIONAL\n" +
      "  {\n" + 
      "    ?j cbc:hasValue ?v .\n" + 
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
