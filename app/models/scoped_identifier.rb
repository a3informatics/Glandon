require "nokogiri"
require "uri"

class ScopedIdentifier

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :identifier, :version, :internalVersion, :namespace
  validates_presence_of :identifier, :version, :internalVersion, :namespace
  
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
      "SELECT ?b ?c ?d ?e WHERE \n" +
      "{ \n" +
      "  :" + id + " isoI:identifier ?b . \n" +
      "  :" + id + " isoI:version ?c . \n" +
      "  :" + id + " isoI:internalVersion ?d . \n" +
      "  :" + id + " isoI:hasScope ?e . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      iSet = node.xpath("binding[@name='b']/literal")
      vSet = node.xpath("binding[@name='c']/literal")
      ivSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/uri")
      if iSet.length == 1 and vSet.length == 1 and ivSet.length == 1
        object = self.new 
        object.id = id
        object.identifier = iSet[0].text
        object.internalVersion = (ivSet[0].text).to_i
        object.version = vSet[0].text
        object.namespace = Namespace.find(ModelUtility.extractCid(sSet[0].text))
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
      "SELECT ?a ?b ?c ?d ?e WHERE \n" +
        "{ \n" +
        "	 ?a rdf:type isoI:ScopedIdentifier . \n" +
        "  ?a isoI:identifier ?b . \n" +
        "	 ?a isoI:version ?c . \n" +
        "  ?a isoI:internalVersion ?d . \n" +
        "  ?a isoI:hasScope ?e . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"all","Node=" + node.to_s)
      uriSet = node.xpath("binding[@name='a']/uri")
      iSet = node.xpath("binding[@name='b']/literal")
      vSet = node.xpath("binding[@name='c']/literal")
      ivSet = node.xpath("binding[@name='d']/literal")
      sSet = node.xpath("binding[@name='e']/uri")
      if uriSet.length == 1 and vSet.length == 1 and iSet.length == 1 and ivSet.length == 1 and sSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.identifier = iSet[0].text
        object.internalVersion = (ivSet[0].text).to_i
        object.version = vSet[0].text
        object.namespace = Namespace.find(ModelUtility.extractCid(sSet[0].text))
        ConsoleLogger::log(C_CLASS_NAME,"all","Created object=" + object.id)
        results.push (object)
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    namespaceId = params[:namespace_id]
    internalVersion = params[:internalVersion].to_i
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
      "	 :" + id + " isoI:internalVersion \"" + internalVersion.to_s + "\"^^xsd:positiveInteger . \n" +
      "  :" + id + " isoI:version \"" + version.to_s + "\"^^xsd:string . \n" +
      "	 :" + id + " isoI:hasScope :" + namespaceId.to_s + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.internalVersion = internalVersion
      object.version = version
      object.identifier = identifier
      object.namespace = Namespace.find(namespaceId)
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
    return nil
  end
  
end