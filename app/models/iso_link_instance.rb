require "nokogiri"
require "uri"

class IsoLinkInstance 

  include CRUD
  include ModelUtility
  
  attr_accessor :rdfType, :range, :domain, :objectUri, :label, :defintion
  
  def self.findForConcept(id, ns)
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoC"]) +
      "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
        "{ \n" +
        "  ?a rdfs:subPropertyOf isoC:link . \n" +
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
      objectUri = ModelUtility.getValue('b', true, node)
      domain = ModelUtility.getValue('c', true, node)
      range = ModelUtility.getValue('d', true, node)
      label = ModelUtility.getValue('e', false, node)
      defintion = ModelUtility.getValue('f', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      if name != ""
        object = self.new 
        object.rdfType = rdfType 
        object.range = range
        object.domain = domain 
        object.label = label
        object.objectUri = objectUri
        object.defintion = defintion
        results.push(object)
      end
    end
    return results
    
  end

end