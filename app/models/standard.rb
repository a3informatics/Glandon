require "uri"

class Standard
  
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include Xml
  include Xslt
      
  attr_accessor :id, :name, :managedItem, :namespace, :type
  validates_presence_of :id, :name, :managedItem, :namespace, :type
  
  # Constants
  C_NS_PREFIX = "mdrStds"
  C_CLASS_NAME = "Standard"
  C_CID_PREFIX = "STD"
  C_SDTM = 1
  C_SDTMIG = 2
  C_UNKNOWN = 3

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

  def baseNs
    return @baseNs
  end
  
  def self.find(id)
    
    object = nil
    query = UriManagement.buildNs(C_NS_PREFIX, ["bo", "bs"]) +
      "SELECT ?a ?b ?type WHERE\n" + 
      "{ \n" + 
      "  { ?a rdf:type bs:Standard } UNION { ?a rdf:type bs:SDTM} UNION { ?a rdf:type bs:SDTMIG } . \n" +
      "  ?a rdf:type ?type . \n" +
      "  ?type rdfs:subClassOf bs:Standard . \n" +
      "  ?a bo:name ?b .\n" + 
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      typeSet = node.xpath("binding[@name='type']/uri")
      if uriSet.length == 1 && nameSet.length == 1 && typeSet.length == 1 
        cid = ModelUtility.extractCid(uriSet[0].text)
        if cid == id
          namespace = ModelUtility.extractNs(uriSet[0].text)
          object = self.new 
          object.id = cid
          object.name = nameSet[0].text
          object.type = getType(typeSet[0].text)
          object.namespace = namespace
          object.managedItem = ManagedItem.find(id, namespace)
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
      end
    end
    return object
  end

  def self.all
    
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["bo", "bs"]) +
      "SELECT ?a ?b ?type WHERE\n" + 
      "{ \n" + 
      "  { ?a rdf:type bs:Standard } UNION { ?a rdf:type bs:SDTM} UNION { ?a rdf:type bs:SDTMIG } . \n" +
      "  ?a rdf:type ?type . \n" +
      "  ?type rdfs:subClassOf bs:Standard . \n" +
      "  ?a bo:name ?b .\n" + 
      "}\n"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      nameSet = node.xpath("binding[@name='b']/literal")
      typeSet = node.xpath("binding[@name='type']/uri")
      ConsoleLogger::log(C_CLASS_NAME,"all","URI=" + uriSet.text)
      if uriSet.length == 1 && nameSet.length == 1 && typeSet.length == 1 
        id = ModelUtility.extractCid(uriSet[0].text)
        namespace = ModelUtility.extractNs(uriSet[0].text)
        object = self.new 
        object.id = id
        object.name = nameSet[0].text
        object.type = getType(typeSet[0].text)
        object.namespace = namespace
        object.managedItem = ManagedItem.find(id, namespace)
        ConsoleLogger::log(C_CLASS_NAME,"all","Object created, id=" + id)
        results[id] = object
      end
    end
    return results  

  end

  def self.create(params)
    return nil
  end

  def update
    return nil
  end

  def destroy
     return nil    
  end

private

  def self.getType (uri)
 
    ConsoleLogger::log(C_CLASS_NAME,"getType","uri=" + uri)
    type = ModelUtility.extractCid(uri)
    ConsoleLogger::log(C_CLASS_NAME,"getType","type=" + type)
    if type == "SDTM"
      type = C_SDTM
    elsif type == "SDTMIG"
      type = C_SDTMIG
    else
      type = C_UNKNOWN
    end
    return type
  
   end  
end
