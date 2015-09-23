require "nokogiri"
require "uri"

class Thesaurus

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :ii_id, :namespace, :version, :identifier
  validates_presence_of :ii_id
 
  # Constants
  C_CLASS_PREFIX = "TH"
  C_NS_PREFIX = "th"
  
  # Base namespace 
  @@baseNs = Namespace.getNs(C_NS_PREFIX)
  
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
    query = Namespace.buildNs(useNs,["isoI"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:identifiedItemRelationship ?a . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      
      p "uri: " + uriSet.text
      
      if uriSet.length == 1
        
        p "Found"
        
        object = self.new 
        object.id = id
        object.namespace = useNs
        object.ii_id = ModelUtility.extractCid(uriSet[0].text)
        ii = IdentifiedItem.find(object.ii_id)
        @identifier = ii.identifier
        @version = ii.version
      
      end
    end
    
    # Return
    return object
    
  end

  def self.findByOrgId(id)
    
    results = Array.new
    
    query = Namespace.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "  ?a isoI:identifiedItemRelationship ?b . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      iiSet = node.xpath("binding[@name='b']/uri")
      
      p "URI: " + uriSet.text
      p "ii: " + iiSet.text
      
      if uriSet.length == 1 and iiSet.length == 1
        
        p "Found"
        
        ii_id = ModelUtility.extractCid(iiSet[0].text)
        
        p "ii_id=" + ii_id
        
        ii = IdentifiedItem.find(ii_id)
        if (ii != nil)
          if (ii.organization_id == id)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.ii_id = ii_id
            object.identifier = ii.identifier
            object.version = ii.version
            results.push (object)
            
            p "TH identifier=" + object.identifier
            p "TH version=" + object.version
            
          end 
        end
        
      end
    end
    
    return results
    
  end
  
  def self.findWithoutNs(id)
    
    object = nil
    
    query = Namespace.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "  ?a isoI:identifiedItemRelationship ?b . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      iiSet = node.xpath("binding[@name='b']/uri")
      
      p "URI: " + uriSet.text
      p "ii: " + iiSet.text
      
      if uriSet.length == 1 and iiSet.length == 1
        
        p "Found"
        
        tId = ModelUtility.extractCid(uriSet[0].text)
        if (tId == id)
          ii_id = ModelUtility.extractCid(iiSet[0].text)
          ii = IdentifiedItem.find(ii_id)
          if (ii != nil)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.ii_id = ii_id
            object.identifier = ii.identifier
            object.version = ii.version
            
            p "TH identifier=" + object.identifier
            p "TH version=" + object.version
          
          end
        end
      end
    end
    
    return object
    
  end
  
  def self.all
    
    results = Array.new
    
    # Create the query
    query = Namespace.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "  ?a isoI:identifiedItemRelationship ?b . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      iiSet = node.xpath("binding[@name='b']/uri")
      
      p "URI: " + uriSet.text
      p "ii: " + iiSet.text
      
      if uriSet.length == 1 and iiSet.length == 1
        
        p "Found"
        
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.namespace = ModelUtility.extractNs(uriSet[0].text)
        object.ii_id = ModelUtility.extractCid(iiSet[0].text)
        ii = IdentifiedItem.find(object.ii_id)
        object.identifier = ii.identifier
        object.version = ii.version
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.create(params,ns="")
    
    ii_id = params[:ii_id]
    ii = IdentifiedItem.find(ii_id)
    
    uri = Uri.new()
    useNs = ns || @@baseNs
    uri.setCidWithVersion(C_CLASS_PREFIX, ii.shortName, ii.version)     
    id = uri.getCid()
    
    # Create the query
    update = Namespace.buildNs(useNs,["isoI", "iso25964", "org"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type iso25964:Thesaurus . \n" +
      "	 :" + id + " isoI:identifiedItemRelationship org:" + ii_id + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.namespace = useNs
      object.ii_id = ii_id
      object.identifier = ii.identifier
      object.version = ii.version
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
    update = Namespace.buildNs(useNs,["isoI", "iso25964", "org"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + self.id + " rdf:type iso25964:Thesaurus . \n" +
      "	 :" + self.id + " isoI:identifiedItemRelationship org:" + self.ii_id.to_s + " . \n" +
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