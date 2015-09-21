require "nokogiri"
require "uri"

class Thesaurus

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :ii_id
  validates_presence_of :ii_id
 
  # Constants
  C_CLASS_PREFIX = "TH"
  C_NS_PREFIX = "th"
  
  # Base namespace 
  @@ns = Namespace.find(C_NS_PREFIX)
  
  def persisted?
    id.present?
  end
 
  #def initialize()
  #  
  #  after_initialize
  #
  #end

  def self.ns
    
    return @@ns 
    
  end
  
  def name
    
    if self.ii_id == nil
      return ""
    else
      ii = IdentifiedItem.find(self.ii_id)
      return ii.name
    end
    
  end
  
  def version
    
    if self.ii_id == nil
      return ""
    else
      ii = IdentifiedItem.find(self.ii_id)
      return ii.version
    end
    
  end
  
  def identifier
    
    if self.ii_id == nil
      return ""
    else
      ii = IdentifiedItem.find(self.ii_id)
      return ii.identifier
    end
    
  end
  
  def self.find(id, ns={})
    
    p "Thesaurus id=" + id
    
    object = nil
    uriValue = ns[:value] || @@ns
    prefix = ns[:prefix] || C_NS_PREFIX
    query = Namespace.build(prefix,["isoI"]) +
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
        object.ii_id = ModelUtility.extractCid(uriSet[0].text)
        
      end
    end
    
    # Return
    return object
    
  end

  def self.findByOrgId(id)
    
    results = Array.new
    
    query = Namespace.build("",["isoI", "iso25964"]) +
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
          if (ii.id == id)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            object.ii_id = ii_id
            results.push (object)
          end 
        end
        
      end
    end
    
    return results
    
  end
  
  def self.all
    
    results = Array.new
    
    # Create the query
    query = Namespace.build("",["isoI", "iso25964"]) +
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
        object.ii_id = ModelUtility.extractCid(iiSet[0].text)
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.create(params,ns={})
    
    ii_id = params[:ii_id]
    ii = IdentifiedItem.find(ii_id)
    
    uri = Uri.new()
    uriValue = ns[:value] || @@ns
    prefix = ns[:prefix] || C_NS_PREFIX
    uri.setCidWithVersion(C_CLASS_PREFIX, ii.shortName, ii.version)     
    id = uri.getCid()
    
    # Create the query
    update = Namespace.build(prefix,["isoI", "iso25964", "org"]) +
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
      object.ii_id = ii_id
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

  def destroy(ns={})
    
    # Create the query
    uri = Uri.new()
    uriValue = ns[:value] || @@ns
    prefix = ns[:prefix] || C_NS_PREFIX
    update = Namespace.build(prefix,["isoI", "iso25964", "org"]) +
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
  
  #private
  #
  #def after_initialize
  #
  #  @@ns = Namespace.find(C_NS_PREFIX)
  #
  #  p "Thesaurus After Initialize"
  #
  #  #end
  
end