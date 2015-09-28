require "nokogiri"
require "uri"

class IdentifiedItem

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :version, :organization_id, :shortName
  validates_presence_of :identifier, :version, :organization_id, :shortName
  
  # Constants
  C_NS_PREFIX = "org"
  C_CLASS_PREFIX = "II"
        
  # Base namespace 
  @@baseNs = Namespace.getNs(C_NS_PREFIX)
  
  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def baseNs
    return @@baseNs 
  end
  
  def self.find(id)
    
    object = nil
    
    # Create the query
    query = Namespace.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:identifier ?b . \n" +
      "  :" + id + " isoI:version ?c . \n" +
      "  :" + id + " isoI:scopeRelationship ?d . \n" +
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
      linkSet = node.xpath("binding[@name='d']/uri")
      
      p "Id: " + iSet.text
      p "Ver: " + vSet.text
      p "link: " + linkSet.text

      if iSet.length == 1 and vSet.length == 1 and linkSet.length == 1
        object = self.new 
        object.id = id
        object.shortName = ModelUtility.extractShortName(id)
        object.identifier = iSet[0].text
        object.version = vSet[0].text
        object.organization_id = ModelUtility.extractCid(linkSet[0].text)
        
        p "II identifier=" + object.identifier
        p "II version=" + object.identifier
        
      end
      
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = Namespace.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
        "{ \n" +
        "	 ?a rdf:type isoI:ScopedIdentifier . \n" +
        "  ?a isoI:identifier ?b . \n" +
        "	 ?a isoI:version ?c . \n" +
        "	 ?a isoI:scopeRelationship ?d . \n" +
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
      linkSet = node.xpath("binding[@name='d']/uri")
      
      p "identifier: " + iSet.text
      p "ver: " + vSet.text
      p "URI: " + uriSet.text
      
      if uriSet.length == 1 and vSet.length == 1 and iSet.length == 1 and linkSet.length == 1

        p "Found"
        
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.shortName = ModelUtility.extractShortName(object.id)
        object.identifier = iSet[0].text
        object.version = vSet[0].text
        object.organization_id = ModelUtility.extractCid(linkSet[0].text)
        results.push (object)
        
        p "II identifier=" + object.identifier
        p "II version=" + object.identifier
        
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    org = params[:organization_id]
    version = params[:version]
    identifier = params[:identifier]
    shortName = params[:shortName]
    id = ModelUtility.buildCidVersion(C_CLASS_PREFIX, shortName, version)
    
    p "Org_id=" + org.to_s
    
    # Create the query
    update = Namespace.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	 :" + id + " isoI:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:version \"" + version.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:scopeRelationship :" + org.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.shortName = shortName
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
    update = Namespace.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + self.id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	 :" + self.id + " isoI:identifier  \"" + self.identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " isoI:version \"" + self.version.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " isoB:registrationAuthorityNamespaceRelationship :" + self.organization_id.to_s + " . \n" +
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