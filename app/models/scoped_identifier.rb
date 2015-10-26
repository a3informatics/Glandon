require "nokogiri"
require "uri"

class ScopedIdentifier

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :version, :namespaceId, :shortName
  validates_presence_of :identifier, :version, :namespaceId, :shortName
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CLASS_PREFIX = "SI"
  C_CLASS_NAME = "ScopedIdentifier"
        
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
  
  def self.find(id)
    
    object = nil
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id.to_s)
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?b ?c ?d WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:identifier ?b . \n" +
      "  :" + id + " isoI:version ?c . \n" +
      "  :" + id + " isoI:hasScope ?d . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      iSet = node.xpath("binding[@name='b']/literal")
      vSet = node.xpath("binding[@name='c']/literal")
      linkSet = node.xpath("binding[@name='d']/uri")
      if iSet.length == 1 and vSet.length == 1 and linkSet.length == 1
        object = self.new 
        object.id = id
        object.shortName = ModelUtility.extractShortName(id)
        object.identifier = iSet[0].text
        object.version = (vSet[0].text).to_i
        object.namespaceId = ModelUtility.extractCid(linkSet[0].text)
        ConsoleLogger::log(C_CLASS_NAME,"find","Object=" + id)
      end
      
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a ?b ?c ?d WHERE \n" +
        "{ \n" +
        "	 ?a rdf:type isoI:ScopedIdentifier . \n" +
        "  ?a isoI:identifier ?b . \n" +
        "	 ?a isoI:version ?c . \n" +
        "	 ?a isoI:hasScope ?d . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      vSet = node.xpath("binding[@name='c']/literal")
      iSet = node.xpath("binding[@name='b']/literal")
      linkSet = node.xpath("binding[@name='d']/uri")
      if uriSet.length == 1 and vSet.length == 1 and iSet.length == 1 and linkSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.shortName = ModelUtility.extractShortName(object.id)
        object.identifier = iSet[0].text
        object.version = (vSet[0].text).to_i
        object.namespaceId = ModelUtility.extractCid(linkSet[0].text)
        results.push (object)
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    namespaceId = params[:namespace_id]
    version = params[:version]
    identifier = params[:identifier]
    shortName = params[:shortName]
    id = ModelUtility.buildCidVersion(C_CLASS_PREFIX, shortName, version)
    
    # Create the query
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	 :" + id + " isoI:identifier \"" + identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:version \"" + version.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:hasScope :" + namespaceId.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.shortName = shortName
      object.version = (version).to_i
      object.identifier = identifier
      object.namespaceId = namespaceId
    else
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
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + self.id + " rdf:type isoI:ScopedIdentifier . \n" +
      "	 :" + self.id + " isoI:identifier  \"" + self.identifier.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " isoI:version \"" + self.version.to_s + "\"^^xsd:string . \n" +
      "	 :" + self.id + " isoI:hasScope :" + self.namespaceId.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"delete","Deleted Id=" + self.id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"delete","Failed to deleted Id=" + self.id)
    end
     
  end
  
end