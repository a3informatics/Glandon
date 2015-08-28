require "typhoeus"
require "zlib"
require "stringio"
require "Nokogiri"

class Organization

  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :name
  validates_presence_of :name

  def persisted?
    id.present?
  end
 
  def self.find(id)
    return nil
  end

  def self.where(parameters={})
    
    results = Array.new
    
    endpoint = "https://rdf.s4.ontotext.com/4830471037/Test/repositories/mdr"
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
    key = "s4h7h1e8absr"
    secret = "47q8uce2r1b4cri"
    headers = {'Accept' => "application/sparql-results+xml",
            'Content-type'=> "application/x-www-form-urlencoded"}

    hydra = Typhoeus::Hydra.hydra
    req = Typhoeus::Request.new(endpoint,
        method: :post,
        userpwd: key + ":" + secret, 
        body: data,
        headers: headers)
    hydra.queue(req)
    hydra.run
    response = req.response
    
    p response.body
    
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//literal").each do |node|
    
      p "Node value: " + node.text
    
      org = Organization.new
      results.push (org)
    end
    return results
    
  end

  def self.all
    return self.where
  end

  def self.create(id)
    endpoint = "https://rdf.s4.ontotext.com/4830471037/Test/repositories/mdr/statements"
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
    key = "s4h7h1e8absr"
    secret = "47q8uce2r1b4cri"
    headers = {'Content-type'=> "application/x-www-form-urlencoded"}

    hydra = Typhoeus::Hydra.hydra
    req = Typhoeus::Request.new(endpoint,
        method: :post,
        userpwd: key + ":" + secret, 
        body: data,
        headers: headers)
    hydra.queue(req)
    hydra.run
    response = req.response
    if response.success?
      object = self.new
      p "It worked!"
    else
      p "It didn't work!"
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
  end

  def self.update(id)
    return nil
  end

  def self.destroy(id)
    return nil   
  end
  
end