require "nokogiri"

class Organization

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :name
  validates_presence_of :name

  C_NS = "http://www.assero.co.uk/MDROrganizations" 
  C_PREFIX = "org" + ": <" + C_NS + "#>"
  C_PREFIXES = ["isoB: <http://www.assero.co.uk/ISO11179Basic#>" ,
        "isoI: <http://www.assero.co.uk/ISO11179Identification#>" ,
        "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" ,
        "rdfs: <http://www.w3.org/2000/01/rdf-schema#>" ,
        "xsd: <http://www.w3.org/2001/XMLSchema#>" ]
  C_O_PREFIX = "O"
  C_NS_PREFIX = "NS"
  
  def persisted?
    id.present?
  end
 
  def self.find(id)
    
    resultOrg = nil
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "SELECT ?b WHERE \n" +
      "{ \n" +
      "org:" + id.to_s  + " isoI:namingAuthorityRelationship ?a . \n" +
      "	?a isoB:name ?b ; \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//literal").each do |node|
      org = Organization.new
      org.name = node.text
      org.id = id
      resultOrg = org
    end
    
    # Return
    return resultOrg
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "SELECT ?a ?c WHERE \n" +
      "{ \n" +
      "	?a rdf:type isoI:Namespace . \n" +
      "	?a isoI:namingAuthorityRelationship ?b . \n" +
      "	?b isoB:name ?c; \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      literalSet = node.xpath("binding[@name='c']/literal")
      uriSet = node.xpath("binding[@name='a']/uri")

      p "Literal: " + literalSet.text
      p "URI: " + uriSet.text

      if uriSet.length == 1 and literalSet.length == 1

        p "Found: " + literalSet[0].text

        org = self.new 
        org.id = ModelUtility.URIGetId(uriSet[0].text)
        org.name = literalSet[0].text
        results.push (org)
      end
    end
    
    # Return
    return results
    
  end

  def self.create(params)
    
    unique = params[:name]
    name = unique.to_s
    
    # Create the query
    orgId = ModelUtility.BuildId(C_O_PREFIX, unique.to_s)
    id = ModelUtility.BuildId(C_NS_PREFIX, unique.to_s)
    update = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "INSERT DATA \n" +
      "{ \n" +
      "	org:" + orgId + " rdf:type isoB:Organization . \n" +
      "	org:" + orgId + " isoB:name \"" + name + "\"^^xsd:string . \n" +
      "	org:" + id + " rdf:type isoI:Namespace . \n" +
      "	org:" + id + " isoI:namingAuthorityRelationship org:" + orgId + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      object = self.new
      object.id = id
      object.name = name
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
    unique = ModelUtility.URIGetUnique(self.id)
    orgId = ModelUtility.BuildId(C_O_PREFIX, unique)
    update = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "DELETE DATA \n" +
      "{ \n" +
      "	org:" + orgId + "  rdf:type isoB:Organization . \n" +
      "	org:" + orgId + " isoB:name \"" + self.id.to_s + "\"^^xsd:string . \n" +
      "	org:" + self.id + " rdf:type isoI:Namespace . \n" +
      "	org:" + self.id + " isoI:namingAuthorityRelationship org:" + orgId + " . \n" +
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