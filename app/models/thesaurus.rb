require "nokogiri"
require "uri"

class Thesaurus

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :scopedIdentifierId, :namespace, :version, :identifier, :created
  validates_presence_of :scopedIdentifierId
 
  # Constants
  C_CID_PREFIX = "TH"
  C_NS_PREFIX = "th"
  
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
    useNs = ns || @@baseNs
    query = UriManagement.buildNs(useNs,["isoI", "iso25964"]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:hasIdentifier ?a . \n" +
      "  :" + id + " iso25964:created ?b . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      dSet = node.xpath("binding[@name='b']/literal")
      
      p "uri: " + uriSet.text
      
      if uriSet.length == 1
        
        p "Found"
        
        object = self.new 
        object.id = id
        object.namespace = useNs
        object.scopedIdentifierId = ModelUtility.extractCid(uriSet[0].text)
        si = ScopedIdentifier.find(object.scopedIdentifierId)
        object.identifier = si.identifier
        object.version = si.version
        object.created = dSet[0].text
        
      end
    end
    
    # Return
    return object
    
  end

  def self.findByNamespaceId(id)
    
    results = Array.new
    
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b ?c WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "  ?a isoI:hasIdentifier ?b . \n" +
      "  ?a iso25964:created ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      siSet = node.xpath("binding[@name='b']/uri")
      dSet = node.xpath("binding[@name='c']/literal")
      
      p "URI: " + uriSet.text
      p "si: " + siSet.text
      
      if uriSet.length == 1 and siSet.length == 1
        
        p "Found"
        
        scopedIdentifierId = ModelUtility.extractCid(siSet[0].text)
        
        p "scopedIdentifierId=" + scopedIdentifierId
        
        si = ScopedIdentifier.find(scopedIdentifierId)
        if (si != nil)
          if (si.namespaceId == id)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.scopedIdentifierId = scopedIdentifierId
            object.identifier = si.identifier
            object.version = si.version
            object.created = dSet[0].text
            results.push (object)
            
            p "TH identifier=" + object.identifier
            p "TH version=" + object.version.to_s
            
          end 
        end
        
      end
    end
    
    return results
    
  end
  
  def self.findWithoutNs(id)
    
    p "[Thesaurus           ][findWithoutNs      ] id=" + id
    
    object = nil
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b ?c WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "  ?a isoI:hasIdentifier ?b . \n" +
      "  ?a iso25964:created ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      siSet = node.xpath("binding[@name='b']/uri")
      dSet = node.xpath("binding[@name='c']/literal")
      
      p "URI: " + uriSet.text
      p "si: " + siSet.text
      
      if uriSet.length == 1 and siSet.length == 1
        
        p "Found"
        
        tId = ModelUtility.extractCid(uriSet[0].text)
        if (tId == id)
          scopedIdentifierId = ModelUtility.extractCid(siSet[0].text)
          si = ScopedIdentifier.find(scopedIdentifierId)
          if (si != nil)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.scopedIdentifierId = scopedIdentifierId
            object.identifier = si.identifier
            object.version = si.version
            object.created = dSet[0].text
            
            p "TH identifier=" + object.identifier
            p "TH version=" + object.version.to_s
          
          end
        end
      end
    end
    
    return object
    
  end
  
  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b ?c WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "  ?a isoI:hasIdentifier ?b . \n" +
      "  ?a iso25964:created ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      siSet = node.xpath("binding[@name='b']/uri")
      dSet = node.xpath("binding[@name='c']/literal")
      
      p "URI: " + uriSet.text
      p "si: " + siSet.text
      
      if uriSet.length == 1 and siSet.length == 1
        
        p "Found"
        
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.namespace = ModelUtility.extractNs(uriSet[0].text)
        object.scopedIdentifierId = ModelUtility.extractCid(siSet[0].text)
        si = ScopedIdentifier.find(object.scopedIdentifierId)
        object.identifier = si.identifier
        object.version = si.version
        object.created = dSet[0].text
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.create(params, ns="")
    
    scopedIdentifierId = params[:scopedIdentifierId]
    si = ScopedIdentifier.find(scopedIdentifierId)
    dateCreated = params[:created]
    
    uri = Uri.new()
    useNs = ns || @@baseNs
    uri.setCidWithVersion(C_CID_PREFIX, si.shortName, si.version)     
    id = uri.getCid()
    
    # Create the query
    update = UriManagement.buildNs(useNs,["isoI", "iso25964", "org"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type iso25964:Thesaurus . \n" +
      "	 :" + id + " isoI:hasIdentifier org:" + scopedIdentifierId + " . \n" +
      "  :" + id + " iso25964:created \"" + dateCreated + "\"^^xsd:date . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.namespace = useNs
      object.scopedIdentifierId = scopedIdentifierId
      object.identifier = si.identifier
      object.version = si.version
      object.created = dateCreated
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

  def destroy(ns="")
    
    # Create the query
    uri = Uri.new()
    useNs = ns || @@baseNs
    update = UriManagement.buildNs(useNs,["isoI", "iso25964", "org"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + self.id + " rdf:type iso25964:Thesaurus . \n" +
      "	 :" + self.id + " isoI:hasIdentifier org:" + self.scopedIdentifierId.to_s + " . \n" +
      "  :" + self.id + " iso25964:created \"" + self.created + "\"^^xsd:date . \n" +
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