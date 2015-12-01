require "nokogiri"
require "uri"

class IsoPropertyInstance 

  include CRUD
  include ModelUtility
  
  attr_accessor :rdfType, :value, :domain, :datatype, :label, :definition
  
  def self.findForConcept(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"findForConcept","*****Entry*****")
    results = Array.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoC"]) +
      "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
        "{ \n" +
        "  ?a rdfs:subPropertyOf isoC:property . \n" +
        "  :" + id + " ?a ?b . \n" +
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
      rdfType = ModelUtility.getValue('a', true, node)
      value = ModelUtility.getValue('b', false, node)
      domain = ModelUtility.getValue('c', true, node)
      range = ModelUtility.getValue('d', false, node)
      label = ModelUtility.getValue('e', false, node)
      definition = ModelUtility.getValue('f', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      if rdfType != ""
        object = self.new 
        object.rdfType = ModelUtility.extractCid(rdfType) 
        object.value = value 
        object.domain = domain
        object.datatype = range
        object.label = label
        object.definition = definition
        ConsoleLogger::log(C_CLASS_NAME,"findForConcept","Object created, rdfType=" + object.rdfType)
        results.push(object)
      end
    end
    return results
    
  end

  # Not tested as yet
  def self.create(id, ns, properties, prefixes)

    sparql = ""
    properties.each do |property|
      sparql += " :" + id + " " + property[:predicate] + " "
      if property.has_key?(:objectProperty)
        sparql += property[:objectProperty] + " . \n"
      else
        sparql += property[:datatypePropertyValue] + "^^" + property[:datatypePropertyType] " . \n"
      end    
    end

    update = UriManagement.buildNs(ns, prefixes) +
      "INSERT DATA \n" +
      "{ \n" + sparql + "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Success, id=" + id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"create_placeholder","Failed")
    end

  end
end