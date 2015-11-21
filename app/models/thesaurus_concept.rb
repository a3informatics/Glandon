require "nokogiri"
require "uri"

class ThesaurusConcept

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :topLevel, :children, :namespace
  validates_presence_of :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :topLevel, :children, :namespace
  
  # Constants
  C_CLASS_PREFIX = "THC"
  C_NS_PREFIX = "mdrTh"
  C_CLASS_NAME = "ThesaurusConcept"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)     
  
  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def self.baseNs
    return @@baseNs 
  end
  
  def self.exists?(identifier, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")

    result = false
    useNs = ns || @@baseNs
    id = ModelUtility.buildCid(useNs, identifier)
    
    # Create the query
    query = UriManagement.buildNs(useNs, ["iso25964"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  :" + id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "  :" + id + " iso25964:identifier ?a . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"exists?","Node=" + node.to_s)
      idReturned = ModelUtility.getValue('a', false, node)
      if idReturned == identifier
        result = true
      end
    end
    
    # Return
    return result
    
  end

  def self.find(id, ns=nil)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")

    object = nil
    
    # Create the query
    useNs = ns || @@baseNs
    query = UriManagement.buildNs(useNs, ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "{ \n" +
      "	 :" + id + " iso25964:identifier ?a . \n" +
      "	 :" + id + " iso25964:notation ?b . \n" +
      "	 :" + id + " iso25964:preferredTerm ?c . \n" +
      "	 :" + id + " iso25964:synonym ?d . \n" +
      "	 :" + id + " iso25964:definition ?f . \n" +
      "	 OPTIONAL\n" +
      "  {\n" +
      "    :" + id + " iso25964:extensible ?e . \n" +
      "    :" + id + " skos:inScheme ?g . \n" +
      "  }\n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      idSet = node.xpath("binding[@name='a']/literal")
      nSet = node.xpath("binding[@name='b']/literal")
      ptSet = node.xpath("binding[@name='c']/literal")
      sSet = node.xpath("binding[@name='d']/literal")
      eSet = node.xpath("binding[@name='e']/literal")
      dSet = node.xpath("binding[@name='f']/literal")
      eSet = node.xpath("binding[@name='e']/literal")
      isSet = node.xpath("binding[@name='g']/uri")
      if idSet.length == 1
        object = self.new 
        object.id = id
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.definition = dSet[0].text
        object.children = allChildren(id, useNs)
        if eSet.length == 1
          object.extensible = eSet[0].text
        else
          object.extensible = ""
        end
        if isSet.length == 1
          object.topLevel = true
        else
          object.topLevel = false
        end   
      end
    end
    
    # Return
    return object
    
  end

  # Find all the lower level items for a given top-level identifier
  #def self.findByIdentifier(identifier, termId, ns=nil)
  #  
  #  ConsoleLogger::log(C_CLASS_NAME,"findByIdentifier","identifier=" + identifier)
  #  ConsoleLogger::log(C_CLASS_NAME,"findByIdentifier","ns=" + ns)
  #  results = Array.new
  #  
  #  # Create the query
  #  useNs = ns || @@baseNs
  #  query = UriManagement.buildNs(useNs, ["iso25964"]) +
  #    "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
  #    "{ \n" +
  #    "	 ?a iso25964:identifier \"" + identifier + "\"^^xsd:string . \n" +
  #    "  ?g skos:narrower ?a . \n" +
  #    "  ?g skos:inScheme :" + termId + " . \n" +
  #    "	 ?a iso25964:notation ?b . \n" +
  #    "	 ?a iso25964:preferredTerm ?c . \n" +
  #    "	 ?a iso25964:synonym ?d . \n" +
  #    "	 ?a iso25964:definition ?f . \n" +
  #    "	 OPTIONAL\n" +
  #    "  {\n" +
  #    "    ?a iso25964:extensible ?e . \n" +
  #    "  }\n" +
  #    "}"
  #  
  #  # Send the request, wait the resonse
  #  response = CRUD.query(query)
  #  
  #  # Process the response
  #  xmlDoc = Nokogiri::XML(response.body)
  #  xmlDoc.remove_namespaces!
  #  xmlDoc.xpath("//result").each do |node|
  #    uriSet = node.xpath("binding[@name='a']/uri")
  #    nSet = node.xpath("binding[@name='b']/literal")
  #    ptSet = node.xpath("binding[@name='c']/literal")
  #    sSet = node.xpath("binding[@name='d']/literal")
  #    eSet = node.xpath("binding[@name='e']/literal")
  #    dSet = node.xpath("binding[@name='f']/literal")
  #    if uriSet.length == 1
  #      ConsoleLogger::log(C_CLASS_NAME,"findByIdentifier","uri=" + uriSet[0].text)
  #      object = self.new 
  #      object.id = ModelUtility.extractCid(uriSet[0].text)
  #      object.identifier = identifier
  #      object.notation = nSet[0].text
  #      object.preferredTerm = ptSet[0].text
  #      object.synonym = sSet[0].text
  #      object.definition = dSet[0].text
  #      object.topLevel = false
  #      if eSet.length == 1
  #        object.extensible = eSet[0].text
  #      else
  #        object.extensible = ""
  #      end 
  #      results.push(object) 
  #    end
  #  end
  #  
  #  # Return
  #  return results
  #  
  #end
  
  def self.all()
    
    ConsoleLogger::log(C_CLASS_NAME,"all","*****Entry*****")

    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "	 ?a iso25964:identifier ?b . \n" +
      "	 ?a iso25964:notation ?c . \n" +
      "	 ?a iso25964:preferredTerm ?d . \n" +
      "	 ?a iso25964:synonym ?e . \n" +
      "	 ?a iso25964:extensible ?f . \n" +
      "	 ?a iso25964:definition ?g . \n" +
      "} ORDER BY ?b"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      idSet = node.xpath("binding[@name='b']/literal")
      nSet = node.xpath("binding[@name='c']/literal")
      ptSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/literal")
      eSet = node.xpath("binding[@name='f']/literal")
      dSet = node.xpath("binding[@name='g']/literal")
      if uriSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.extensible = eSet[0].text
        object.definition = dSet[0].text
        object.children = nil
        results.push (object)
      end
    end
    return results
    
  end
  
  #def self.allTopLevel()
  #  
  #  results = Array.new
  #  
  #  # Create the query
  #  query = UriManagement.buildPrefix("", ["iso25964"]) +
  #    "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
  #    "{ \n" +
  #    "	 ?a rdf:type iso25964:ThesaurusConcept . \n" +
  #    "  ?a skos:inScheme ?h . \n" +
  #    "	 ?a iso25964:identifier ?b . \n" +
  #    "	 ?a iso25964:notation ?c . \n" +
  #    "	 ?a iso25964:preferredTerm ?d . \n" +
  #    "	 ?a iso25964:synonym ?e . \n" +
  #    "	 ?a iso25964:extensible ?f . \n" +
  #    "	 ?a iso25964:definition ?g . \n" +
  #    "}"
  #  
  #  # Send the request, wait the resonse
  #  response = CRUD.query(query)
  #  
  #  # Process the response
  # xmlDoc = Nokogiri::XML(response.body)
  #  xmlDoc.remove_namespaces!
  #  xmlDoc.xpath("//result").each do |node|
  #    
  #    #p "Node: " + node.text
  #    
  #    uriSet = node.xpath("binding[@name='a']/uri")
  #    idSet = node.xpath("binding[@name='b']/literal")
  #    nSet = node.xpath("binding[@name='c']/literal")
  #    ptSet = node.xpath("binding[@name='d']/literal")
  #    sSet = node.xpath("binding[@name='e']/literal")
  #    eSet = node.xpath("binding[@name='f']/literal")
  #    dSet = node.xpath("binding[@name='g']/literal")
  #    
  #    if uriSet.length == 1 
  #      
  #      #p "Found"
  #      
  #      object = self.new 
  #      object.id = ModelUtility.extractCid(uriSet[0].text)
  #      object.identifier = idSet[0].text
  #      object.notation = nSet[0].text
  #      object.preferredTerm = ptSet[0].text
  #      object.synonym = sSet[0].text
  #      object.extensible = eSet[0].text
  #      object.definition = dSet[0].text
  #      object.topLevel = true
  #      results.push (object)
  #      
  #    end
  #  end
  #  
  #  return results
  #  
  #end

  def self.allTopLevel(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"allTopLevel","*****Entry*****")

    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "	 { \n" +
      "    ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "    ?a skos:inScheme :" + id + " . \n" +
      "	   ?a iso25964:identifier ?b . \n" +
      "	   ?a iso25964:notation ?c . \n" +
      "	   ?a iso25964:preferredTerm ?d . \n" +
      "	   ?a iso25964:synonym ?e . \n" +
      "	   ?a iso25964:extensible ?f . \n" +
      "	   ?a iso25964:definition ?g . \n" +
      "} ORDER BY ?b"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"allTopLevel","Node=" + node.to_s)
      uriSet = node.xpath("binding[@name='a']/uri")
      idSet = node.xpath("binding[@name='b']/literal")
      nSet = node.xpath("binding[@name='c']/literal")
      ptSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/literal")
      eSet = node.xpath("binding[@name='f']/literal")
      dSet = node.xpath("binding[@name='g']/literal")
      if uriSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.extensible = eSet[0].text
        object.definition = dSet[0].text
        object.topLevel = true
        object.children = nil
        results[object.id] = object
        ConsoleLogger::log(C_CLASS_NAME,"allTopLevel","Object created, id=" + object.id)
      end
    end
    return results
    
  end
  
  # Find all children of a given concept (identified by the CID)
  def self.allChildren(id, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"allChildren","*****Entry*****")

    # Create empty array for the results
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
      "{\n" +
      "  :" + id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "  :" + id + " skos:narrower ?a . \n" +
      "  ?a iso25964:identifier ?b .  \n" +
      "  ?a iso25964:definition ?c . \n" +
      "  ?a iso25964:synonym ?d . \n" +
      "  ?a iso25964:preferredTerm ?e . \n" +
      "  ?a iso25964:notation ?f .	\n" +
      "} ORDER BY ?b"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"allChildren","Node=" + node.to_s)
      uriSet = node.xpath("binding[@name='a']/uri")
      idSet = node.xpath("binding[@name='b']/literal")
      dSet = node.xpath("binding[@name='c']/literal")
      sSet = node.xpath("binding[@name='d']/literal")
      ptSet = node.xpath("binding[@name='e']/literal")
      nSet = node.xpath("binding[@name='f']/literal")
      if uriSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.definition = dSet[0].text
        object.extensible = ""
        object.topLevel = false
        object.children = nil
        results[object.id] = object
        ConsoleLogger::log(C_CLASS_NAME,"allChildren","Object created, id=" + object.id)
      end
    end
    return results
    
  end
  
  def self.searchTextWithNs(termId, ns, term)
    
    ConsoleLogger::log(C_CLASS_NAME,"searchTextWithNs","Id=" + termId.to_s + ", ns=" + ns.to_s + ", term=" + term)
    results = Array.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["iso25964"]) +
      "SELECT DISTINCT ?a ?b ?c ?d ?e ?f ?g ?h WHERE \n" +
      "  {\n" +
      "    ?a iso25964:identifier ?b . \n" +
      "    ?a iso25964:notation ?c . \n" +
      "    ?a iso25964:preferredTerm ?d . \n" +
      "    ?a iso25964:synonym ?e . \n" +
      "    ?a iso25964:definition ?g . \n" +
      "    OPTIONAL\n" +
      "    {\n" +
      "      ?a iso25964:extensible ?f . \n" +
      "      ?a skos:inScheme ?h . \n" +
      "    }\n" +
      "    ?a ( iso25964:notation | iso25964:preferredTerm | iso25964:synonym | iso25964:definition ) ?i . FILTER regex(?i, \"" + term + "\") . \n" +
      "    {\n" +
      "      SELECT ?a WHERE\n" +
      "      {\n" +
      "        ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "        { ?a skos:inScheme :" + termId + " } UNION { ?j skos:inScheme :" + termId + " . ?j skos:narrower ?a } . \n" +
      "      }\n" +
      "    }\n" +
      "  } ORDER BY ?b"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"searchTextWithNs","Node=" + node.to_s)
      uriSet = node.xpath("binding[@name='a']/uri")
      idSet = node.xpath("binding[@name='b']/literal")
      nSet = node.xpath("binding[@name='c']/literal")
      ptSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/literal")
      eSet = node.xpath("binding[@name='f']/literal")
      dSet = node.xpath("binding[@name='g']/literal")
      tlSet = node.xpath("binding[@name='h']/uri")
      if uriSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.namespace = ModelUtility.extractNs(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.children = nil
        if eSet.length == 1 
          object.extensible = eSet[0].text
        else
          object.extensible = ""
        end
        if tlSet.length == 1 
          object.topLevel = true
        else
          object.topLevel = false
        end
        object.definition = dSet[0].text
        results.push (object)
      end
    end
    return results
    
  end

  def self.searchIdentifierWithNs(termId, ns, term)
    
    # Quick and dirty implementation
    ConsoleLogger::log(C_CLASS_NAME,"searchIdentifierWithNs","Entry")
    ConsoleLogger::log(C_CLASS_NAME,"searchIdentifierWithNs","Id=" + termId.to_s + ", ns=" + ns.to_s + ", term=" + term)
    results = Array.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["iso25964"]) +
      "SELECT DISTINCT ?a ?b ?c ?d ?e ?f ?g ?h WHERE \n" +
      "  {\n" +
      "    ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "    ?a skos:inScheme :" + termId + " . \n" +
      "    ?a iso25964:notation ?b . \n" +
      "    ?a iso25964:identifier \"" + term + "\" . \n" +
      "    ?a iso25964:preferredTerm ?c . \n" +
      "    ?a iso25964:synonym ?d . \n" +
      "    ?a iso25964:definition ?e . \n" +
      "    ?a iso25964:identifier ?f . \n" +
      "    OPTIONAL\n" +
      "    {\n" +
      "      ?a iso25964:extensible ?g . \n" +
      "    }\n" +
      "  }\n"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nSet = node.xpath("binding[@name='b']/literal")
      ptSet = node.xpath("binding[@name='c']/literal")
      sSet = node.xpath("binding[@name='d']/literal")
      dSet = node.xpath("binding[@name='e']/literal")
      eSet = node.xpath("binding[@name='g']/literal")
      idSet = node.xpath("binding[@name='f']/literal")
      tlSet = node.xpath("binding[@name='g']/literal")
      if uriSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.definition = dSet[0].text
        object.children = nil
        if eSet.length == 1 
          object.extensible = eSet[0].text
        else
          object.extensible = false
        end
        object.topLevel = true
        results.push (object)
      end
    end
    
  # Create the query
    query = UriManagement.buildNs(ns, ["iso25964"]) +
      "SELECT DISTINCT ?a ?b ?c ?d ?e ?f ?g ?h WHERE \n" +
      "  {\n" +
      "    ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "    ?a skos:inScheme :" + termId + " . \n" +
      "    ?a iso25964:identifier \"" + term + "\" . \n" +
      "    ?a skos:narrower ?h . \n" +
      "    ?h iso25964:notation ?b . \n" +
      "    ?h iso25964:preferredTerm ?c . \n" +
      "    ?h iso25964:synonym ?d . \n" +
      "    ?h iso25964:definition ?e . \n" +
      "    ?h iso25964:identifier ?f . \n" +
      "    OPTIONAL\n" +
      "    {\n" +
      "      ?h iso25964:extensible ?g . \n" +
      "    }\n" +
      "  }\n"

    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='h']/uri")
      nSet = node.xpath("binding[@name='b']/literal")
      ptSet = node.xpath("binding[@name='c']/literal")
      sSet = node.xpath("binding[@name='d']/literal")
      dSet = node.xpath("binding[@name='e']/literal")
      eSet = node.xpath("binding[@name='g']/literal")
      idSet = node.xpath("binding[@name='f']/literal")
      tlSet = node.xpath("binding[@name='g']/literal")
      if uriSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.definition = dSet[0].text
        object.children = nil
        if eSet.length == 1 
          object.extensible = eSet[0].text
        else
          object.extensible = false
        end
        object.topLevel = false
        results.push (object)
      end
    end
   
    return results
    
  end

  def self.create(params, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")

    object = nil

    identifier  = params[:identifier]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    extensible = params[:extensible]
    definition = params[:definition]
    
    # Create the query
    id = ModelUtility.buildCid(ns, identifier)
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "	 :" + id + " iso25964:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:preferredTerm \"" + preferredTerm.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:synonym \"" + synonym.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:extensible \"" + extensible.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " iso25964:definition \"" + definition.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.identifier = identifier
      object.notation = notation
      object.preferredTerm = preferredTerm
      object.synonym = synonym
      object.extensible = extensible
      object.definition = definition
      object.children = nil
        p "It worked!"
    else
      p "It didn't work!"
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def self.createTopLevel(params, ns, thesauriId)
    
    ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","ns=" + ns)
    ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","thId=" + thesauriId)

    identifier  = params[:identifier]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    extensible = params[:extensible]
    definition = params[:definition]

    ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","params=" + params.to_s)
    
    # Create the query
    id = ModelUtility.buildCid(ns, identifier)
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "  :" + id + " skos:inScheme :" + thesauriId + " . \n" +
      "  :" + id + " iso25964:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:preferredTerm \"" + preferredTerm.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:synonym \"" + synonym.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:extensible \"" + extensible.to_s + "\"^^xsd:string . \n" +
      "  :" + id + " iso25964:definition \"" + definition.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.identifier = identifier
      object.notation = notation
      object.preferredTerm = preferredTerm
      object.synonym = synonym
      object.extensible = extensible
      object.definition = definition
      object.children = nil
      ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","Object created, id=" + id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","Object created failed!")
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end
  
  def addChild(child, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"addChild","*****Entry*****")

    # Create the query
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + self.id + " skos:narrower :" + child.id + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      self.children = ThesaurusConcept::allChildren(self.id, ns)
      ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","Object created, id=" + self.id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"createTopLevel","Object created failed!")
      object.assign_errors(data) if response.response_code == 422
    end
    
  end

  def update(params, ns)
    
    ConsoleLogger::log(C_CLASS_NAME,"update","*****Entry*****")

    # Note extensible cannot be modified.
    identifier  = params[:identifier]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    extensible = self.extensible
    definition = params[:definition]

    # Create the query
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "DELETE { :" + self.id + " ?p ?o } \n" +
      "INSERT \n" +
      "{ \n" +
      #"  :" + self.id + " rdf:type iso25964:ThesaurusConcept . \n" +
      #"  :" + self.id + " skos:inScheme :?o2 . \n" +
      "  :" + self.id + " iso25964:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:notation \"" + notation.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:preferredTerm \"" + preferredTerm.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:synonym \"" + synonym.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:extensible \"" + extensible.to_s + "\"^^xsd:string . \n" +
      "  :" + self.id + " iso25964:definition \"" + definition.to_s + "\"^^xsd:string . \n" +
      "} \n" +
      "WHERE \n" +
      "{\n" +
      "  :" + self.id + " (iso25964:identifier|iso25964:notation|iso25964:preferredTerm|iso25964:synonym|iso25964:extensible|iso25964:definition) ?o .\n" +
      "}\n"
      
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      self.children = ThesaurusConcept::allChildren(self.id, ns)
      ConsoleLogger::log(C_CLASS_NAME,"updated","Object created, id=" + self.id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"updated","Object created failed!")
      object.assign_errors(data) if response.response_code == 422
    end
  end

  def destroy(ns, thesauriId)
    
    ConsoleLogger::log(C_CLASS_NAME,"destroy","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"destroy","Namespace=" + ns)

    # Create the query
    update = UriManagement.buildNs(ns, ["iso25964"]) +
      "DELETE \n" +
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "  ?c skos:narrower :" + self.id + " . \n" +
      "}\n" +
      "WHERE\n" + 
      "{\n" +
      "  :" + self.id + " ?a ?b . \n" +
      "  OPTIONAL \n" +
      "  {\n" +
      "    ?c iso25964:inScheme :" + thesauriId + " . \n" +
      "    ?c skos:narrower :" + self.id + " . \n" +
      "  }\n" +
      "}\n"

    # Create the query
    # update = UriManagement.buildPrefix(C_NS_PREFIX, ["iso25964"]) +
    #   "DELETE DATA \n" +
    #   "{ \n" +
    #   "	 :" + self.id + " rdf:type iso25964:ThesaurusConcept . \n" +
    #   "  :" + self.id + " iso25964:identifier \"" + self.identifier.to_s + "\"^^xsd:string . \n" +
    #   "	 :" + self.id + " iso25964:notation \"" + self.notation.to_s + "\"^^xsd:string . \n" +
    #   "	 :" + self.id + " iso25964:preferredTerm \"" + self.preferredTerm.to_s + "\"^^xsd:string . \n" +
    #   "	 :" + self.id + " iso25964:synonym \"" + self.synonym.to_s + "\"^^xsd:string . \n" +
    #   "	 :" + self.id + " iso25964:extensible \"" + self.extensible.to_s + "\"^^xsd:string . \n" +
    #   "	 :" + self.id + " iso25964:definition \"" + self.definition.to_s + "\"^^xsd:string . \n" +
    #   "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Object deleted")
    else
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Object deletion failed!")
    end
     
  end
  
  def to_D3

    result = Hash.new
    result[:name] = self.identifier
    result[:identifier] = self.identifier
    result[:notation] = self.notation
    result[:definition] = self.definition
    result[:synonym] = self.synonym
    result[:preferredTerm] = self.preferredTerm
    result[:children] = Array.new

    index = 0
    self.children.each do |key, child|
      result[:children][index] = Hash.new
      result[:children][index][:name] = child.identifier + ' [' + child.notation + ']'
      result[:children][index][:identifier] = child.identifier
      result[:children][index][:id] = child.id
      result[:children][index][:notation] = child.notation
      result[:children][index][:definition] = child.definition
      result[:children][index][:synonym] = child.synonym
      result[:children][index][:preferredTerm] = child.preferredTerm
      result[:children][index][:expand] = false
      result[:children][index][:endIndex] = 0
      result[:children][index][:startIndex] = 0
      result[:children][index][:expansion] = Array.new        
      index += 1
    end
    return result

  end
end