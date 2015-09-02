require "nokogiri"

class Organization

  include Rest
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :name
  validates_presence_of :name

  def persisted?
    id.present?
  end
 
  def self.find(id)
    
    resultOrg = nil
    
    # Create the query
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    endpoint = SEMANTIC_DB_CONFIG['queryEndpoint']
    data = "query=PREFIX org: <http://www.assero.co.uk/MDROrganizations#> \n" +
    "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#> \n" + 
    "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#> \n" + 
    "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" + 
    "SELECT ?a WHERE \n" +
    "{ \n" +
    "	?a rdf:type isoI:Namespace . \n" +
    "	?a isoI:namingAuthorityRelationship ?b . \n" +
    "	?b isoB:name '" + id.to_s + "'^^<http://www.w3.org/2001/XMLSchema#string> ; \n" +
    "}"
    headers = {'Accept' => "application/sparql-results+xml",
            'Content-type'=> "application/x-www-form-urlencoded"}
    
    p "Find query=" + data
            
    # Send the request, wait the resonse
    response = Rest.sendRequest(endpoint,:post,key + ":" + secret,data,headers)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//uri").each do |node|
    
      p "Node value: " + node.text
    
      org = Organization.new
      org.name = id
      org.id = id
      resultOrg = org
    end
    return resultOrg
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    endpoint = SEMANTIC_DB_CONFIG['queryEndpoint']
    data = "query=PREFIX org: <http://www.assero.co.uk/MDROrganizations#> \n" +
    "PREFIX isoI: <http://www.assero.co.uk/ISO11179Identification#> \n" + 
    "PREFIX isoB: <http://www.assero.co.uk/ISO11179Basic#> \n" + 
    "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" + 
    "SELECT ?name WHERE \n" +
    "{ \n" +
    "	?a rdf:type isoI:Namespace . \n" +
    "	?a isoI:namingAuthorityRelationship ?b . \n" +
    "	?b isoB:name ?name; \n" +
    "}"
    headers = {'Accept' => "application/sparql-results+xml",
            'Content-type'=> "application/x-www-form-urlencoded"}
    
    # Send the request, wait the resonse
    response = Rest.sendRequest(endpoint,:post,key + ":" + secret,data,headers)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//literal").each do |node|
    
      p "Node value: " + node.text
    
      org = Organization.new
      org.name = node.text
      org.id = node.text
      results.push (org)
    end
    return results
    
  end

  def self.create(params)
    
    id = params[:name]
    
    # Create the query
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    endpoint = SEMANTIC_DB_CONFIG['updateEndpoint']
    data = "update=PREFIX org: <http://www.assero.co.uk/MDROrganizations#> \n" +
    "PREFIX ISO11179Basic: <http://www.assero.co.uk/ISO11179Basic#> \n" +
    "PREFIX ISO11179Identification: <http://www.assero.co.uk/ISO11179Identification#> \n" +
    "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
    "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n" +
    "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
    "INSERT DATA \n" +
    "{ \n" +
    "	org:" + id.to_s + "  rdf:type ISO11179Basic:Organization . \n" +
    "	org:" + id.to_s + " ISO11179Basic:name \"" + id.to_s + "\"^^xsd:string . \n" +
    "	org:" + id.to_s + "NS rdf:type ISO11179Identification:Namespace . \n" +
    "	org:" + id.to_s + "NS ISO11179Identification:namingAuthorityRelationship org:" + id.to_s + " . \n" +
    "}"
    headers = {'Content-type'=> "application/x-www-form-urlencoded"}

    p "Create query=" + data
    
    # Send the request, wait the resonse
    response = Rest.sendRequest(endpoint,:post,key + ":" + secret,data,headers)

    # Response
    if response.success?
      object = self.new
      object.id = id
      object.name = id
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
    key = SEMANTIC_DB_CONFIG['apiKey'] 
    secret = SEMANTIC_DB_CONFIG['secret']
    endpoint = SEMANTIC_DB_CONFIG['updateEndpoint']
    data = "update=PREFIX org: <http://www.assero.co.uk/MDROrganizations#> \n" +
    "PREFIX ISO11179Basic: <http://www.assero.co.uk/ISO11179Basic#> \n" +
    "PREFIX ISO11179Identification: <http://www.assero.co.uk/ISO11179Identification#> \n" +
    "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \n" +
    "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \n" +
    "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
    "DELETE DATA \n" +
    "{ \n" +
    "	org:" + self.id.to_s + "  rdf:type ISO11179Basic:Organization . \n" +
    "	org:" + self.id.to_s + " ISO11179Basic:name \"" + self.id.to_s + "\"^^xsd:string . \n" +
    "	org:" + self.id.to_s + "NS rdf:type ISO11179Identification:Namespace . \n" +
    "	org:" + self.id.to_s + "NS ISO11179Identification:namingAuthorityRelationship org:" + self.id.to_s + " . \n" +
    "}"
    headers = {'Content-type'=> "application/x-www-form-urlencoded"}

    p "Create query=" + data
    
    # Send the request, wait the resonse
    response = Rest.sendRequest(endpoint,:post,key + ":" + secret,data,headers)

    # Response
    if response.success?
      p "It worked!"
    else
      p "It didn't work!"
    end
     
  end
  
end