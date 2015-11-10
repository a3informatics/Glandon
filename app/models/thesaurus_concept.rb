require "nokogiri"
require "uri"

class ThesaurusConcept

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :topLevel, :namespace
  validates_presence_of :identifier, :notation, :synonym, :extensible, :definition, :preferredTerm, :topLevel, :namespace
  
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
  
  def self.find(id, ns="")
    
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
  def self.findByIdentifier(identifier, termId, ns="")
    
    ConsoleLogger::log(C_CLASS_NAME,"findByIdentifier","identifier=" + identifier)
    ConsoleLogger::log(C_CLASS_NAME,"findByIdentifier","ns=" + ns)
    results = Array.new
    
    # Create the query
    useNs = ns || @@baseNs
    query = UriManagement.buildNs(useNs, ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f WHERE \n" +
      "{ \n" +
      "	 ?a iso25964:identifier \"" + identifier + "\"^^xsd:string . \n" +
      "  ?g skos:narrower ?a . \n" +
      "  ?g skos:inScheme :" + termId + " . \n" +
      "	 ?a iso25964:notation ?b . \n" +
      "	 ?a iso25964:preferredTerm ?c . \n" +
      "	 ?a iso25964:synonym ?d . \n" +
      "	 ?a iso25964:definition ?f . \n" +
      "	 OPTIONAL\n" +
      "  {\n" +
      "    ?a iso25964:extensible ?e . \n" +
      "  }\n" +
      "}"
    
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
      eSet = node.xpath("binding[@name='e']/literal")
      dSet = node.xpath("binding[@name='f']/literal")
      if uriSet.length == 1
        ConsoleLogger::log(C_CLASS_NAME,"findByIdentifier","uri=" + uriSet[0].text)
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = identifier
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.definition = dSet[0].text
        object.topLevel = false
        if eSet.length == 1
          object.extensible = eSet[0].text
        else
          object.extensible = ""
        end 
        results.push(object) 
      end
    end
    
    # Return
    return results
    
  end
  
  def self.all()
    
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
        results.push (object)
      end
    end
    return results
    
  end
  
  def self.allTopLevel()
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix("", ["iso25964"]) +
      "SELECT ?a ?b ?c ?d ?e ?f ?g WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "  ?a skos:inScheme ?h . \n" +
      "	 ?a iso25964:identifier ?b . \n" +
      "	 ?a iso25964:notation ?c . \n" +
      "	 ?a iso25964:preferredTerm ?d . \n" +
      "	 ?a iso25964:synonym ?e . \n" +
      "	 ?a iso25964:extensible ?f . \n" +
      "	 ?a iso25964:definition ?g . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      #p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      idSet = node.xpath("binding[@name='b']/literal")
      nSet = node.xpath("binding[@name='c']/literal")
      ptSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/literal")
      eSet = node.xpath("binding[@name='f']/literal")
      dSet = node.xpath("binding[@name='g']/literal")
      
      if uriSet.length == 1 
        
        #p "Found"
        
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.extensible = eSet[0].text
        object.definition = dSet[0].text
        object.topLevel = true
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.allTopLevelWithNs(id, ns)
    
    p "[ThesaurusConcept    ][allTopLevelWithNs  ] ns=" + ns
    
    results = Array.new
    
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
    
      p "[ThesaurusConcept   ][allWithNs         ] node=" + node.text
    
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
        results.push (object)
      end
    end
    return results
    
  end
  
  def self.allLowerLevelWithNs(id, ns)
    
    p "[ThesaurusConcept   ][allLowerLevelWithNs] id=" + id
    p "[ThesaurusConcept   ][allLowerLevelWithNs] ns=" + ns
    
    # Create empty array for the results
    results = Array.new
    
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
    
      p "[ThesaurusConcept   ][allLowerLevelWithNs] node=" + node.text
    
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
        results.push (object)
        
        p "[ThesaurusConcept   ][allLowerLevelWithNs] obj=" + object.id
        
      end
    end
    return results
    
  end
  
  def self.searchTextWithNs(termId, ns, term)
    
    ConsoleLogger::log(C_CLASS_NAME,"searchAllTopLevelWithNs","Id=" + termId.to_s + ", ns=" + ns.to_s + ", term=" + term)
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
      ConsoleLogger::log(C_CLASS_NAME,"searchAllTopLevelWithNs","Node=" + node.to_s)
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
    
    ConsoleLogger::log(C_CLASS_NAME,"searchAllTopLevelWithNs","Id=" + termId.to_s + ", ns=" + ns.to_s + ", term=" + term)
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
      "    {\n" +
      "      SELECT ?a WHERE\n" +
      "      {\n" +
      "        ?a rdf:type iso25964:ThesaurusConcept . \n" +
      "        { ?k skos:inScheme :" + termId + " . ?k iso25964:identifier \"" + term + "\"^^xsd:string . ?k skos:narrower ?a } UNION \n" + 
      "        { ?a skos:inScheme :" + termId + " . ?a iso25964:identifier \"" + term + "\"^^xsd:string . } UNION \n" + 
      "        { ?j skos:inScheme :" + termId + " . ?j skos:narrower ?a . ?a iso25964:identifier \"" + term + "\"^^xsd:string } . \n" +
      "      }\n" +
      "    }\n" +
      "  } ORDER BY ?b"
  
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
      dSet = node.xpath("binding[@name='g']/literal")
      eSet = node.xpath("binding[@name='f']/literal")
      tlSet = node.xpath("binding[@name='h']/uri")
      if uriSet.length == 1 
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = idSet[0].text
        object.notation = nSet[0].text
        object.preferredTerm = ptSet[0].text
        object.synonym = sSet[0].text
        object.definition = dSet[0].text
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
        results.push (object)
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    identifier  = params[:identifier]
    notation = params[:notation]
    preferredTerm = params[:preferredTerm]
    synonym = params[:synonym]
    extensible = params[:extensible]
    definition = params[:definition]
    
    # Create the query
    id = ModelUtility.buildCid(C_CLASS_PREFIX, identifier)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["iso25964"]) +
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
      p "It worked!"
    else
      p "It didn't work!"
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def update(id)
    return nil
  end

  def destroy
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["iso25964"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + self.id + " rdf:type iso25964:ThesaurusConcept . \n" +
      "  :" + self.id + " iso25964:identifier \"" + self.identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:notation \"" + self.notation.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:preferredTerm \"" + self.preferredTerm.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:synonym \"" + self.synonym.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:extensible \"" + self.extensible.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " iso25964:definition \"" + self.definition.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      p "It worked!"
    else
      p "It didn't work!"
    end
     
  end
  
end