require "uri"

class Domain
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :managedItem, :name, :variables, :namespace
  validates_presence_of :id, :managedItem, :name, :variables, :namespace
  # Constants
  C_NS_PREFIX = "mdrDomains"
  C_CLASS_NAME = "Domain"
  C_CID_PREFIX = "D"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  
  def version
    return self.managedItem.version
  end

  def internalVersion
    return self.managedItem.internalVersion
  end

  def identifier
    return self.managedItem.identifier
  end

  def persisted?
    id.present?
  end
  
  def initialize()
  end

  def baseNs
    return @baseNs
  end

  # Find a given domain
  def self.find(id, domainNamespace)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"find","Namespace=" + domainNamespace)
    object = nil
    query = UriManagement.buildNs(domainNamespace, ["bo","bd","bs","mms"]) +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " :" + id + " bo:name ?a . \n" +
      " :" + id + " bs:usedBy ?b . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      nameSet = node.xpath("binding[@name='a']/literal")
      igSet = node.xpath("binding[@name='b']/uri")
      if igSet.length == 1 && nameSet.length == 1 
        namespace = domainNamespace
        object = self.new 
        object.id = id
        object.name = nameSet[0].text
        object.namespace = namespace
        ConsoleLogger::log(C_CLASS_NAME,"find","Namespace=" + namespace)
        object.managedItem = ManagedItem.find(id, namespace)
        object.variables = Domain::Variable.findForDomain(id, namespace)
        ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id.to_s)
      end
    end
    return object
    
  end

  # Find domains for an specified SDTM IG
  def self.findForIg(igId, igNamespace)
    
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"find","Namespace=" + igNamespace)
    results = Hash.new
    query = UriManagement.buildNs(igNamespace, ["bo","bd", "bs"]) +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bd:Domain . \n" +
      " ?a bo:name ?b . \n" +
      " ?a bs:usedBy :" + igId + " . \n" +
      "} \n"
                  
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      if uriSet.length == 1 && nameSet.length == 1 
        id = ModelUtility.extractCid(uriSet[0].text)
        namespace = ModelUtility.extractNs(uriSet[0].text)
        object = self.new 
        object.id = id
        object.name = nameSet[0].text
        object.namespace = namespace
        ConsoleLogger::log(C_CLASS_NAME,"find","Namespace=" + namespace)
        object.managedItem = ManagedItem.find(id, namespace)
        object.variables = Hash.new
        ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id.to_s)
        results[id] = object
      end
    end
    return results  
    
  end

  def self.all()
    
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bd", "bd"]) 
    query = query +
      "SELECT ?a ?b WHERE\n" + 
      "{ \n" + 
      " ?a rdf:type bd:Domain . \n" +
      " ?a bo:name ?b . \n" +
      "} \n"
      
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nSet = node.xpath("binding[@name='b']/literal")
      if uriSet.length == 1 && nSet.length == 1 
        namespace = ModelUtility.extractNs(uriSet[0].text)
        id = ModelUtility.extractCid(uriSet[0].text)
        object = self.new 
        object.id = id
        object.namespace = namespace
        ConsoleLogger::log(C_CLASS_NAME,"all","Id=" + id.to_s)
        object.managedItem = ManagedItem.find(id, ModelUtility.extractNs(uriSet[0].text))
        object.name = nSet[0].text
        object.variables = Hash.new
        results[object.id] = object
      end
    end
    return results  
    
  end

  def self.create(params)
    object = nil
    return object
  end

  def update
    return nil
  end

  def destroy
  end
  
end
