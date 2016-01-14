class IsoConcept

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
    
  attr_accessor :id, :namespace, :rdfType, :label, :properties, :links
  
  # Constants
  C_CID_PREFIX = "ISOC"
  C_NS_PREFIX = "mdrCons"
  C_CLASS_NAME = "IsoConcept"
  
  C_RDF_TYPE = "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
  C_RDFS_LABEL = "http://www.w3.org/2000/01/rdf-schema#label"
  C_ISO_LINK = "http://www.assero.co.uk/ISO11179Concepts#link"
  C_ISO_PROPERTY = "http://www.assero.co.uk/ISO11179Concepts#property"

  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def persisted?
    id.present?
  end
 
  # Does the item exist. Cannot be used for child objects!
  def self.exists?(property, propertyValue, rdfType, schemaNs, instanceNs)
    #ConsoleLogger::log(C_CLASS_NAME,"exists?","*****Entry*****")
    result = false
    
    # Create the query
    prefix = UriManagement.getPrefix(schemaNs)
    prefixSet = []
    prefixSet << prefix
    query = UriManagement.buildNs(instanceNs, prefixSet) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type " + prefix + ":" + rdfType + " . \n" +
      "  ?a " + prefix + ":" + property + " \"" + propertyValue + "\" . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    if xmlDoc.xpath("//result").length >= 1
      result = true
    end
    
    # Return
    return result
  end

  # Note: The id is the identifier for the enclosing managed object. 
  def self.find(id, ns)
    object = nil
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoC"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  :" + id + " ?a ?b . \n" +
      "  OPTIONAL { ?a rdfs:subPropertyOf ?c . ?a rdfs:label ?d . }\n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node)
      predicate = ModelUtility.getValue('a', true, node)
      objectUri = ModelUtility.getValue('b', true, node)
      objectLiteral = ModelUtility.getValue('b', false, node)
      plSubProperty = ModelUtility.getValue('c', true, node)
      objectLabel = ModelUtility.getValue('d', false, node)
      if predicate != ""
        #ConsoleLogger::log(C_CLASS_NAME,"find","Predicate")
        if object == nil
          object = self.new
          object.id = id
          object.namespace = ns
          object.properties = IsoProperty.new
          object.links = IsoLink.new
          object.label = ""
          object.rdfType = ""
        end
        if predicate == C_RDF_TYPE
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","RDF Type")
          object.rdfType = objectUri
        elsif predicate == C_RDFS_LABEL
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","RDFS Label")
          object.label = objectLiteral
        elsif plSubProperty == C_ISO_LINK
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","Link")
          object.links.set(predicate, objectUri)
        elsif plSubProperty == C_ISO_PROPERTY
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","Property")
          object.properties.set(predicate, objectLiteral, objectLabel)
        end
      end
    end
    #ConsoleLogger::log(C_CLASS_NAME,"find","Object return, object=" + object.to_s)
    return object
  end

  def self.findWithCondition(conditionTriple, ns, prefixSet)
    #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","*****Entry*****")
    #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","Triple=" + conditionTriple)
    #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","namespace=" + ns)
    results = Hash.new

    # Create the query
    prefix = ["isoC"] + prefixSet
    query = UriManagement.buildNs(ns, prefix) +
      "SELECT ?a ?b ?c ?d ?e WHERE \n" +
      "{ \n" +
      conditionTriple + " . \n" +
      "  ?a ?b ?c . \n" +
      "  OPTIONAL { ?b rdfs:subPropertyOf ?d . ?b rdfs:label ?e . FILTER(STRSTARTS(STR(?d), \"http://www.assero.co.uk/ISO11179Concepts#\")). }\n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","Node=" + node)
      subject = ModelUtility.getValue('a', true, node)
      predicate = ModelUtility.getValue('b', true, node)
      objectUri = ModelUtility.getValue('c', true, node)
      objectLiteral = ModelUtility.getValue('c', false, node)
      plSubProperty = ModelUtility.getValue('d', true, node)
      objectLabel = ModelUtility.getValue('e', false, node)
      if subject != ""
        #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","Predicate")
        id = ModelUtility.extractCid(subject)
        if results.has_key?(id)
          object = results[id]
        else
          object = self.new
          object.id = id
          object.namespace = ModelUtility.extractNs(subject)
          object.properties = IsoProperty.new
          object.links = IsoLink.new
          object.label = ""
          object.rdfType = ""
          results[id] = object
        end
        if predicate == C_RDF_TYPE
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","RDF Type")
          object.rdfType = objectUri
        elsif predicate == C_RDFS_LABEL
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","RDFS Label")
          object.label = objectLiteral
        elsif plSubProperty == C_ISO_LINK
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","Link")
          object.links.set(predicate, objectUri)
        elsif plSubProperty == C_ISO_PROPERTY
          #ConsoleLogger::log(C_CLASS_NAME,"findWithCondition","Property")
          object.properties.set(predicate, objectLiteral, objectLabel)
        end
      end
    end
    return results
  end

  def self.findForParent(prefix, rdfType, links, ns)    
    #ConsoleLogger::log(C_CLASS_NAME,"findForParent","*****ENTRY******")
    #ConsoleLogger::log(C_CLASS_NAME,"findForParent","Type=" + rdfType + ", links=" + links.to_json + ", ns=" + ns)
    results = Hash.new
    linkSet = links.get(prefix, rdfType)
    linkSet.each do |link|
      object = find(ModelUtility.extractCid(link), ns)
      results[object.id] = object
    end
    return results
  end

  def self.findForChild(prefix, rdfType, links, ns)    
    results = Hash.new
    linkSet = links.get(prefix, rdfType)
    linkSet.each do |link|
      object = find(ModelUtility.extractCid(link), ns)
      results[object.id] = object
    end
    return results
  end

  def self.all(rdfType, ns)
    #ConsoleLogger::log(C_CLASS_NAME,"all","*****Entry*****")
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(ns, ["isoI", "isoT"]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type :" + rdfType + " . \n" +
      "  ?a rdfs:label ?b . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uri = ModelUtility.getValue('a', true, node)
      label = ModelUtility.getValue('b', false, node)
      ConsoleLogger::log(C_CLASS_NAME,"find","Label=" + label)
      if uri != "" && label != ""
        object = self.new
        object.id = ModelUtility.extractCid(uri)
        object.namespace = ModelUtility.extractNs(uri)
        object.rdfType = rdfType
        object.label = label
      end
    end
    
    # Return
    return results
  end

  def self.create(prefix, params, rdfType, schemaNs, instanceNs)
  
    ConsoleLogger::log(C_CLASS_NAME,"create","*****Entry*****")
    
    object = self.new
    object.id = ModelUtility.buildCidIdentifier(prefix, params[:identifier])
    object.label = ""
    object.rdfType = params[:rdfType]

    prefixSet = ["mdrItems", "isoI"]
    prefixSet << UriManagement.getPrefix(schemaNs)
    update = UriManagement.buildNs(instanceNs, prefixSet) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + object.id + " rdf:type :" + object.rdfType + " . \n" +
      "  :" + object.id + " rdfs:label \"" + object.label + "\"^^xsd:string . \n" +
      "}"

    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create","Success, id=" + id)
    else
      object = nil
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed")
    end
    return object
  
  end

end