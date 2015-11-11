require "nokogiri"
require "uri"

class Thesaurus

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :namespace
  validates_presence_of :id, :managedItem, :namespace
 
  # Constants
  C_CLASS_NAME = "Thesaurus"
  C_CID_PREFIX = "TH"
  C_NS_PREFIX = "mdrTh"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def version
    return self.managedItem.version
  end

  def versionLabel
    return self.managedItem.versionLabel
  end

  def identifier
    return self.managedItem.identifier
  end

  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def self.baseNs
    return @@baseNs 
  end
  
  def self.find(id, ns=nil)
    
    object = nil
    useNs = ns || @@baseNs
    object = self.new 
    object.id = id
    object.namespace = useNs
    object.managedItem = ManagedItem.find(id,useNs)
    return object
    
  end

  def self.findByNamespaceId(namespaceId)
    
    results = Array.new
    
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b ?c WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1
        managedItem = ManagedItem.find(ModelUtility.extractCid(uriSet[0].text),ModelUtility.extractNs(uriSet[0].text))
        if (managedItem != nil)
          if (managedItem.scopedIdentifier.namespace.id == namespaceId)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.managedItem = managedItem
            results.push (object)
            ConsoleLogger::log(C_CLASS_NAME,"findByNamespaceId","Object created id=" + object.id)
          end 
        end
        
      end
    end
    
    return results
    
  end
  
  def self.findWithoutNs(id)
    
    ConsoleLogger::log(C_CLASS_NAME,"findWithoutNs","id=" + id)
    object = nil
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1 
        tId = ModelUtility.extractCid(uriSet[0].text)
        ConsoleLogger::log(C_CLASS_NAME,"findWithoutNs","tid=" + tId)
        if (tId == id)
          managedItem = ManagedItem.find(ModelUtility.extractCid(uriSet[0].text),ModelUtility.extractNs(uriSet[0].text))
          if (managedItem != nil)
            object = self.new 
            object.id = ModelUtility.extractCid(uriSet[0].text)
            object.namespace = ModelUtility.extractNs(uriSet[0].text)
            object.managedItem = managedItem
            ConsoleLogger::log(C_CLASS_NAME,"findWithoutNs","Object created id=" + object.id)
          end
        end
      end
    end
    
    return object
    
  end
  
  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix("",["isoI", "iso25964"]) +
      "SELECT ?a ?b ?c WHERE \n" +
      "{ \n" +
      "  ?a rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.namespace = ModelUtility.extractNs(uriSet[0].text)
        object.managedItem = ManagedItem.find(object.id,object.namespace)
        results.push (object)
        
      end
    end
    
    return results
    
  end

  def self.createLocal(params, ns=nil)
    
    # Set the namespace
    useNs = ns || @@baseNs
    ConsoleLogger::log(C_CLASS_NAME,"createLocal","useNs=" + useNs)
    
    # Get the parameters
    itemType = params[:itemType]
    version = params[:version]
    versionLabel = params[:versionLabel]
    identifier = params[:identifier]

    # Create the id for the form
    id = ModelUtility.buildCidVersion(C_CID_PREFIX, itemType, version)

    # Create the managed item for the thesaurus. The namespace id is a shortcut for the moment.
    managedItem = ManagedItem.createLocal(id, {:version => version, :identifier => identifier, :versionLabel => versionLabel, :itemType => itemType, :namespaceId => "NS-ACME"}, useNs)

    # Create the query
    update = UriManagement.buildNs(useNs,["isoI", "iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	 :" + id + " rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.namespace = useNs
      object.managedItem = managedItem
      ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object created, id=" + id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"createLocal","Object not created!")
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def self.createImported(params, ns=nil)
    
    # Set the namespaceitemTy
    useNs = ns || @@baseNs

    # Get the parameters
    itemType = params[:itemType]
    version = params[:version]
    versionLabel = params[:versionLabel]
    identifier = params[:identifier]
    namespaceId = params[:namespaceId]

    ConsoleLogger::log(C_CLASS_NAME,"createImported","*****ENTRY*****")
    ConsoleLogger::log(C_CLASS_NAME,"createImported",
      "namespaceId=" + namespaceId + ", " + 
      "versionLabel=" + versionLabel + ", " + 
      "version=" + version + ", " + 
      "identifier" + identifier + ", " + 
      "itemType=" + itemType )

    # Create the id for the form
    id = ModelUtility.buildCidVersion(C_CID_PREFIX, itemType, version)

    # Create the managed item for the thesaurus. The namespace id is a shortcut for the moment.
    managedItem = ManagedItem.createImported(id, {:version => version, :identifier => identifier, :versionLabel => versionLabel, :itemType => itemType, :namespaceId => namespaceId}, useNs)

    # Create the query
    update = UriManagement.buildNs(useNs,["isoI", "iso25964"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "  :" + id + " rdf:type iso25964:Thesaurus . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.namespace = useNs
      object.managedItem = managedItem
      ConsoleLogger::log(C_CLASS_NAME,"createImported","Object created, id=" + id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"createImported","Object not created!")
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def update(id)
    return nil
  end

  def destroy(ns=nil)
    return nil
  end
  
end