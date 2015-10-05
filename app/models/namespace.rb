require "nokogiri"
require "uri"

class Namespace

  include CRUD
  include ModelUtility
  include UriManagement
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :name, :shortName
  validates_presence_of :name, :shortName

  # Constants
  C_NS_PREFIX = "org"
  C_CLASS_O_PREFIX = "O"
  C_CLASS_NS_PREFIX = "NS"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def baseNs    
    return @@baseNs     
  end
  
  def self.findByShortName(name)
    
    object = nil
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a ?c WHERE \n" +
      "{ \n" +
        "?a isoI:namingAuthorityRelationship ?b . \n" +
        "?b isoB:shortName \"" + name + "\"^^xsd:string . \n" +
        "?b isoB:name ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
    
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      nSet = node.xpath("binding[@name='c']/literal")
      
      p "name: " + nSet.text
      p "uri: " + uriSet.text
      
      if nSet.length == 1 and uriSet.length == 1

        p "Found"
        
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.name = nSet[0].text
        object.shortName = name
        
      end
    
    end
    
    # Return
    return object
    
  end
  
  def self.find(id)
    
    object = nil
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b ?c WHERE \n" +
      "{ \n" +
      "  :" + id.to_s + " isoI:namingAuthorityRelationship ?a . \n" +
      "  ?a isoB:shortName ?b . \n" +
      "  ?a isoB:name ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      snSet = node.xpath("binding[@name='b']/literal")
      nSet = node.xpath("binding[@name='c']/literal")
      
      p "name: " + nSet.text
      p "short: " + snSet.text
      
      if nSet.length == 1 and snSet.length == 1

        p "Found"
        
        object = self.new 
        object.id = id
        object.name = nSet[0].text
        object.shortName = snSet[0].text
        
      end
    
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX,["isoI", "isoB"]) +
      "SELECT ?a ?c ?d WHERE \n" +
      "{ \n" +
      "	?a rdf:type isoI:Namespace . \n" +
      "	?a isoI:namingAuthorityRelationship ?b . \n" +
      "	?b isoB:shortName ?c . \n" +
      "	?b isoB:name ?d . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      snSet = node.xpath("binding[@name='c']/literal")
      nSet = node.xpath("binding[@name='d']/literal")
      uriSet = node.xpath("binding[@name='a']/uri")

      p "URI: " + uriSet.text

      if uriSet.length == 1 and snSet.length == 1 and nSet.length == 1

        p "Found: " + snSet[0].text

        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.name = nSet[0].text
        object.shortName = snSet[0].text
        results.push (object)
      end
      
    end
    
    # Return
    return results
    
  end

  def self.create(params)
    
    name = params[:name]
    shortName = params[:shortName]
        
    # Create the query
    orgId = ModelUtility.buildCid(C_CLASS_O_PREFIX, shortName)
    id = ModelUtility.buildCid(C_CLASS_NS_PREFIX, shortName)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + orgId + " rdf:type isoB:Organization . \n" +
      "	 :" + orgId + " isoB:name \"" + name + "\"^^xsd:string . \n" +
      "	 :" + orgId + " isoB:shortName \"" + shortName + "\"^^xsd:string . \n" +
      "	 :" + id + " rdf:type isoI:Namespace . \n" +
      "	 :" + id + " isoI:namingAuthorityRelationship :" + orgId + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      object.name = name
      object.shortName = shortName
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
    orgId = ModelUtility.cidSwapPrefix(self.id, C_CLASS_O_PREFIX)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + orgId + "  rdf:type isoB:Organization . \n" +
      "	 :" + orgId + " isoB:name \"" + self.name + "\"^^xsd:string . \n" +
      "	 :" + orgId + " isoB:shortName \"" + self.shortName + "\"^^xsd:string . \n" +
      "	 :" + self.id + " rdf:type isoI:Namespace . \n" +
      "	 :" + self.id + " isoI:namingAuthorityRelationship :" + orgId + " . \n" +
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