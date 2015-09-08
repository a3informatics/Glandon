require "nokogiri"

class IdentifiedItem

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :version
  validates_presence_of :identifier, :version
  
  C_NS = "http://www.assero.co.uk/MDROrganizations" 
  C_PREFIX = "org" + ": <" + C_NS + "#>"
  C_PREFIXES = ["isoR: <http://www.assero.co.uk/ISO11179Registiition#>" , 
        "isoB: <http://www.assero.co.uk/ISO11179Basic#>" ,
        "isoI: <http://www.assero.co.uk/ISO11179Identification#>" ,
        "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" ,
        "rdfs: <http://www.w3.org/2000/01/rdf-schema#>" ,
        "xsd: <http://www.w3.org/2001/XMLSchema#>" ]
  C_II_PREFIX = "II"
        
  def persisted?
    id.present?
  end
 
  def self.find(id)
    
    object = nil
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "SELECT ?b ?c WHERE \n" +
      "{ \n" +
      "org:" + id + " isoI:identifier ?b . \n" +
      "org:" + id + " isoI:version ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      iSet = node.xpath("binding[@name='b']/literal")
      vSet = node.xpath("binding[@name='c']/literal")
      
      p "Id: " + iSet.text
      p "Ver: " + vSet.text

      if iSet.length == 1 and vSet.length == 1

        p "Found"
        
        object = self.new 
        object.id = id
        object.identifier = iSet[0].text
        object.version = vSet[0].text

      end
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "SELECT ?a ?b ?c WHERE \n" +
        "{ \n" +
        "	?a rdf:type isoI:ScopedIdentifier . \n" +
        " ?a isoI:identifier ?b . \n" +
        "	?a isoI:version ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      uriSet = node.xpath("binding[@name='a']/uri")
      vSet = node.xpath("binding[@name='c']/literal")
      iSet = node.xpath("binding[@name='b']/literal")
      
      p "identifier: " + iSet.text
      p "ver: " + vSet.text
      p "URI: " + uriSet.text
      
      if uriSet.length == 1 and vSet.length == 1 and iSet.length == 1

        p "Found"
        
        object = self.new 
        object.id = ModelUtility.URIGetFragment(uriSet[0].text)
        object.identifier = iSet[0].text
        object.version = vSet[0].text
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    version = params[:version]
    identifier = params[:identifier]
    unique = identifier.to_s + "_" + version.to_s
    unique = unique.parameterize
    
    # Create the query
    id = ModelUtility.BuildFragment(C_II_PREFIX, unique.to_s)
    update = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "INSERT DATA \n" +
      "{ \n" +
      "	org:" + id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	org:" + id + " isoI:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	org:" + id + " isoI:version \"" + version.to_s + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.version = version
      object.identifier = identifier
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
      "	org:" + self.id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	org:" + self.id + " isoI:identifier  \"" + self.identifier.to_s + "\"^^xsd:string . \n" +
      "	org:" + self.id + " isoI:version \"" + self.version.to_s + "\"^^xsd:string . \n" +
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