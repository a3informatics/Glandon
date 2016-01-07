require "nokogiri"
require "uri"

class IsoNamespace

  include CRUD
  include ModelUtility
  include UriManagement
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :namespace, :name, :shortName
  validates_presence_of :id, :namespace, :name, :shortName

  # Constants
  C_NS_PREFIX = "mdrItems"
  C_ORG_CID_PREFIX = "O"
  C_NS_CID_PREFIX = "NS"
  C_CLASS_NAME = "Namespace"
  
  # Base namespace 
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  @@idMap = Hash.new
  @@nameMap = Hash.new
  
  def persisted?
    id.present?
  end

  def initialize()
    self.namespace = ""
    self.name = ""
    self.shortName = ""
  end

  def baseNs    
    return @@baseNs     
  end
  
  def self.exists?(shortName)
    ConsoleLogger::log(C_CLASS_NAME,"exists?","*****ENTRY*****")
    if @@nameMap.has_key?(shortName)
      result = true
    else
      result = false
    
      # Create the query
      query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
        "SELECT ?a ?c WHERE \n" +
        "{ \n" +
          "?a isoI:ofOrganization ?b . \n" +
          "?b isoB:shortName \"" + shortName + "\"^^xsd:string . \n" +
        "}"
      
      # Send the request, wait the resonse
      response = CRUD.query(query)
      
      # Process the response
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        #ConsoleLogger::log(C_CLASS_NAME,"create","Node=" + node.to_s)
        uriSet = node.xpath("binding[@name='a']/uri")
        if uriSet.length == 1
          result = true
          ConsoleLogger::log(C_CLASS_NAME,"exists?","Object exists!")        
        end
      end
      return result
    end
  end

  def self.findByShortName(shortName)
    ConsoleLogger::log(C_CLASS_NAME,"findByShortName","*****ENTRY*****")
    object = nil
    if @@nameMap.has_key?(shortName)
      ConsoleLogger::log(C_CLASS_NAME,"findByShortName","Exisitng entry")
      object = @@nameMap[shortName]
    else
      # Create the query
      query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
        "SELECT ?a ?c WHERE \n" +
        "{ \n" +
          "?a isoI:ofOrganization ?b . \n" +
          "?b isoB:shortName \"" + shortName + "\"^^xsd:string . \n" +
          "?b isoB:name ?c . \n" +
        "}"
      
      # Send the request, wait the resonse
      response = CRUD.query(query)
      
      # Process the response
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        #ConsoleLogger::log(C_CLASS_NAME,"create","Node=" + node.to_s)
        uriSet = node.xpath("binding[@name='a']/uri")
        nSet = node.xpath("binding[@name='c']/literal")
        if nSet.length == 1 and uriSet.length == 1
          object = self.new 
          object.id = ModelUtility::extractCid(uriSet[0].text)
          object.namespace = @@baseNs 
          object.name = nSet[0].text
          object.shortName = shortName
          ConsoleLogger::log(C_CLASS_NAME,"findByShortName","Object created, id=" + object.id)        
          @@nameMap[object.shortName] = object
          @@idMap[object.id] = object
        end
      end
    end
    return object
  end
  
  def self.find(id)
    ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    ConsoleLogger::log(C_CLASS_NAME,"find","Id=" + id)
    ConsoleLogger::log(C_CLASS_NAME,"find","@@idMap=" + @@idMap.to_s)
    object = nil
    if @@idMap.has_key?(id)
      ConsoleLogger::log(C_CLASS_NAME,"find","Exisitng entry")
      object = @@idMap[id]
    else
      
      # Create the query
      query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
        "SELECT ?b ?c WHERE \n" +
        "{ \n" +
        "  :" + id.to_s + " isoI:ofOrganization ?a . \n" +
        "  ?a isoB:shortName ?b . \n" +
        "  ?a isoB:name ?c . \n" +
        "}"
      
      # Send the request, wait the resonse
      response = CRUD.query(query)
      
      # Process the response
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node.to_s)
        snSet = node.xpath("binding[@name='b']/literal")
        nSet = node.xpath("binding[@name='c']/literal")
        if nSet.length == 1 and snSet.length == 1
          object = self.new 
          object.id = id
          object.namespace = @@baseNs 
          object.name = nSet[0].text
          object.shortName = snSet[0].text
          ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
          @@nameMap[object.shortName] = object
          @@idMap[object.id] = object
          ConsoleLogger::log(C_CLASS_NAME,"find","@@idMap=" + @@idMap.to_s)
        end
      
      end
    end    
    return object
  end

  def self.all
    results = Hash.new
    
    # Create the query
    query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
      "SELECT ?a ?c ?d WHERE \n" +
      "{ \n" +
      "	?a rdf:type isoI:Namespace . \n" +
      "	?a isoI:ofOrganization ?b . \n" +
      "	?b isoB:shortName ?c . \n" +
      "	?b isoB:name ?d . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      ConsoleLogger::log(C_CLASS_NAME,"all","Node=" + node.to_s)
      snSet = node.xpath("binding[@name='c']/literal")
      nSet = node.xpath("binding[@name='d']/literal")
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1 and snSet.length == 1 and nSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.namespace = @@baseNs 
        object.name = nSet[0].text
        object.shortName = snSet[0].text
        ConsoleLogger::log(C_CLASS_NAME,"all","Created object=" + object.id)
        @@nameMap[object.shortName] = object
        @@idMap[object.id] = object
        results[object.id] = object
      end
    end
    return results
  end

  def self.create(params)
    object = self.new
    object.errors.clear

    # Check parameters
    if params_valid?(params, object)
      
      # Get the parameters
      name = params[:name]
      shortName = params[:shortName]
      
      # Does the namespace exist?
      if !exists?(shortName)

        # Create the query
        id = ModelUtility.buildCidIdentifier(C_NS_CID_PREFIX, shortName)
        orgId = ModelUtility.cidSwapPrefix(id, C_ORG_CID_PREFIX)
        update = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "	 :" + orgId + " rdf:type isoB:Organization . \n" +
          "	 :" + orgId + " isoB:name \"" + name + "\"^^xsd:string . \n" +
          "	 :" + orgId + " isoB:shortName \"" + shortName + "\"^^xsd:string . \n" +
          "	 :" + id + " rdf:type isoI:Namespace . \n" +
          "	 :" + id + " isoI:ofOrganization :" + orgId + " . \n" +
          "}"
        
        # Send the request, wait the resonse
        response = CRUD.update(update)

        # Response
        if response.success?
          object.id = id
          object.namespace = @@baseNs 
          object.name = name
          object.shortName = shortName
          ConsoleLogger::log(C_CLASS_NAME,"create","Object created, id=" + id)
        else
          ConsoleLogger::log(C_CLASS_NAME,"create","Object not created!")
          object.errors.add(:base, "The namespace was not created in the database.")
          #object.assign_errors(data) if response.response_code == 422
        end
      
      else
        
        # Object exists
        object.errors.add(:base, "The short name entered is already in use.")

      end
    end

    return object
    
  end

  def destroy
    ConsoleLogger::log(C_CLASS_NAME,"destroy","*****Entry*****")

    # Destroy the exisitng maps
    @@idMap = Hash.new
    @@nameMap = Hash.new

    # Create the query
    orgId = ModelUtility.cidSwapPrefix(self.id, C_ORG_CID_PREFIX)
    update = UriManagement.buildNs(self.namespace, ["isoI", "isoB"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	 :" + orgId + "  rdf:type isoB:Organization . \n" +
      "	 :" + orgId + " isoB:name \"" + self.name + "\"^^xsd:string . \n" +
      "	 :" + orgId + " isoB:shortName \"" + self.shortName + "\"^^xsd:string . \n" +
      "	 :" + self.id + " rdf:type isoI:Namespace . \n" +
      "	 :" + self.id + " isoI:ofOrganization :" + orgId + " . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Object destroyed.")
    else
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Object noot destroyed!")
    end
     
  end
   
private

  def self.params_valid?(params, object)
    result1 = ModelUtility::validShortName?(params[:shortName], object)
    result2 = ModelUtility::validFreeText?(:name, params[:name], object)
    return result1 && result2
  end

end