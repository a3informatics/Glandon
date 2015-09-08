require "nokogiri"

class Thesaurus

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :ii_id
  validates_presence_of :ii_id
  
  C_NS = "http://www.assero.co.uk/MDRThesaurus" 
  #C_PREFIX = "org" + ": <" + C_NS + "#>"
  C_PREFIX = ": <" + C_NS + "#>"
  C_PREFIXES = ["iso25964: <http://www.assero.co.uk/ISO25964#>" , 
        "isoI: <http://www.assero.co.uk/ISO11179Identification#>" ,
        "org: <http://www.assero.co.uk/MDROrganization#>" ,
        "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" ,
        "rdfs: <http://www.w3.org/2000/01/rdf-schema#>" ,
        "xsd: <http://www.w3.org/2001/XMLSchema#>" ]
  C_T_PREFIX = "T"
        
  def persisted?
    id.present?
  end
 
  def self.find(id)
    
    object = nil
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
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
        object.ii_id = ModelUtility.URIGetFragment(uriSet[0].text)

      end
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
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
        object.id = ModelUtility.URIGetFragment(uriSet[0].text)
        object.ii_id = ModelUtility.URIGetFragment(iiSet[0].text)
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    ii_id = params[:ii_id]
    ii = IdentifiedItem.find(ii_id)
    
    unique = ii.identifier + "_" + ii.version
    unique = unique.parameterize
    
    # Create the query
    id = ModelUtility.BuildFragment(C_T_PREFIX, unique)
    update = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "INSERT DATA \n" +
      "{ \n" +
      "	:" + id + " rdf:type iso25964:Thesaurus . \n" +
      "	:" + id + " isoI:identifiedItemRelationship org:" + ii_id + " . \n" +
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

  def destroy
    
    # Create the query
    update = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
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