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
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_ORG_CID_PREFIX = "O"
  C_NS_CID_PREFIX = "NS"
  C_CLASS_NAME = "Namespace"
  
  # Class variables
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  @@idMap = Hash.new
  @@nameMap = Hash.new
  
  def persisted?
    id.present?
  end

  # Initialize
  #
  # @return null
  def initialize()
    @@baseNs ||= UriManagement.getNs(C_NS_PREFIX)
    self.id = ""
    self.namespace = ""
    self.name = ""
    self.shortName = ""
  end

  # Does the namespace exist?
  #
  # @return [boolean] True if the namespace exists, false otherwise.
  def exists?
    # Do we have the result stored.
    if @@nameMap.has_key?(shortName)
      result = true
    else
      result = false
      # Create the query, submit
      query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
        "SELECT ?a WHERE \n" +
        "{\n" +
        "  ?a isoI:ofOrganization ?b . \n" +
        "  ?b isoB:shortName \"#{self.shortName}\"^^xsd:string . \n" +
        "}"
      response = CRUD.query(query)
      # Process the response
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        uriSet = node.xpath("binding[@name='a']/uri")
        if uriSet.length == 1
          result = true
        end
      end
      return result
    end
  end

  # Find namespace by the short name.
  #
  # @todo: Better return for not found (will just be empty at the moment)
  #
  # @param shortName [string] The short name of the namespace to be found
  # @return [object] Iso Namespace object
  def self.findByShortName(shortName)
    # Do we have a stored result
    object = self.new
    if @@nameMap.has_key?(shortName)
      object = @@nameMap[shortName]
    else
      # Create the query, submit.
      query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
        "SELECT ?a ?c WHERE \n" +
        "{\n" +
        "  ?a isoI:ofOrganization ?b . \n" +
        "  ?b isoB:shortName \"" + shortName + "\"^^xsd:string . \n" +
        "  ?b isoB:name ?c . \n" +
        "}"
      response = CRUD.query(query)
      # Process the response.
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        uriSet = node.xpath("binding[@name='a']/uri")
        nSet = node.xpath("binding[@name='c']/literal")
        if nSet.length == 1 and uriSet.length == 1
          object.id = ModelUtility::extractCid(uriSet[0].text)
          object.namespace = @@baseNs 
          object.name = nSet[0].text
          object.shortName = shortName
          @@nameMap[object.shortName] = object
          @@idMap[object.id] = object
        end
      end
    end
    return object
  end
  
  # Find based on identifier
  #
  # @param id [string] The id of the object
  # @returns [object] Namespace object
  def self.find(id)
    # Do we have a stored result?
    object = self.new 
    if @@idMap.has_key?(id)
      object = @@idMap[id]
    else
      # Build query and submit.
      query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
        "SELECT ?b ?c WHERE \n" +
        "{\n" +
        "  :" + id.to_s + " isoI:ofOrganization ?a . \n" +
        "  ?a isoB:shortName ?b . \n" +
        "  ?a isoB:name ?c . \n" +
        "}"
      response = CRUD.query(query)
      # Process the reposne.
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        snSet = node.xpath("binding[@name='b']/literal")
        nSet = node.xpath("binding[@name='c']/literal")
        if nSet.length == 1 and snSet.length == 1
          object.id = id
          object.namespace = @@baseNs 
          object.name = nSet[0].text
          object.shortName = snSet[0].text
          @@nameMap[object.shortName] = object
          @@idMap[object.id] = object
        end
      end
    end    
    return object
  end

  # Find all namespace objects
  #
  # @return [hash] Hash of namespace objects
  def self.all
    # Build query and submit.
    results = Array.new
    query = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
      "SELECT ?a ?c ?d WHERE \n" +
      "{\n" +
      "  ?a rdf:type isoI:Namespace . \n" +
      "  ?a isoI:ofOrganization ?b . \n" +
      "  ?b isoB:shortName ?c . \n" +
      "  ?b isoB:name ?d . \n" +
      "}"
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      snSet = node.xpath("binding[@name='c']/literal")
      nSet = node.xpath("binding[@name='d']/literal")
      uriSet = node.xpath("binding[@name='a']/uri")
      if uriSet.length == 1 and snSet.length == 1 and nSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.namespace = @@baseNs 
        object.name = nSet[0].text
        object.shortName = snSet[0].text
        @@nameMap[object.shortName] = object
        @@idMap[object.id] = object
        results << object
      end
    end
    return results
  end

  # Create a namespace object
  #
  # @param params [hash] {name, shortName}
  # @return [object] Namespace object. Errors set if duplicate
  # @raise [ExceptionClass] CreateError if object not created
  def self.create(params)
    object = self.new
    object.name = params[:name]
    object.shortName = params[:shortName]
    if object.valid?
      if !object.exists?
        uri = UriV2.new({:namespace => @@baseNs, :prefix => C_NS_CID_PREFIX, :org_name => object.shortName, :identifier => C_NS_CID_PREFIX})  
        org_uri = UriV2.new({:namespace => @@baseNs, :prefix => C_ORG_CID_PREFIX, :org_name => object.shortName, :identifier => C_NS_CID_PREFIX})  
        update = UriManagement.buildNs(@@baseNs, ["isoI", "isoB"]) +
          "INSERT DATA \n" +
          "{\n" +
          "  :" + org_uri.id + " rdf:type isoB:Organization . \n" +
          "  :" + org_uri.id + " isoB:name \"#{object.name}\"^^xsd:string . \n" +
          "  :" + org_uri.id + " isoB:shortName \"#{object.shortName}\"^^xsd:string . \n" +
          "  :" + uri.id + " rdf:type isoI:Namespace . \n" +
          "  :" + uri.id + " isoI:ofOrganization :#{org_uri.id} . \n" +
          "}"
        response = CRUD.update(update)
        if response.success?
          object.id = uri.id
          object.namespace = @@baseNs 
        else
          ConsoleLogger.info(C_CLASS_NAME,"create", "Failed to create object.")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      else
        object.errors.add(:base, "The short name entered is already in use.")
      end
    end
    return object
  end

  # Destroy a namespace object
  #
  # @return null
  # @raise [ExceptionClass] DestroyError if object not destroyed
  def destroy
    # Destroy the exisitng maps
    @@idMap = Hash.new
    @@nameMap = Hash.new
    # Create the query and submit.
    # orgId = ModelUtility.cidSwapPrefix(self.id, C_ORG_CID_PREFIX)
    org_uri = IsoUtility.uri(self.namespace, self.id)
    org_uri.update_prefix(C_ORG_CID_PREFIX)
    update = UriManagement.buildNs(self.namespace, ["isoI", "isoB"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "  :" + org_uri.id + " rdf:type isoB:Organization . \n" +
      "  :" + org_uri.id + " isoB:name \"" + self.name + "\"^^xsd:string . \n" +
      "  :" + org_uri.id + " isoB:shortName \"" + self.shortName + "\"^^xsd:string . \n" +
      "  :" + self.id + " rdf:type isoI:Namespace . \n" +
      "  :" + self.id + " isoI:ofOrganization :" + org_uri.id + " . \n" +
      "}"
    response = CRUD.update(update)
    # Process the response
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    # Leave the following block in here. Used to test Console Logger & Exception raised were working. Just useful.
    #else
    #  ConsoleLogger::log(C_CLASS_NAME,"destroy", "Object destroyed.")
    #  raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = 
    { 
      :namespace => self.namespace, 
      :id => self.id, 
      :name => self.name,
      :shortName => self.shortName
    }
    return json
  end
  
  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = self.new
    object.id = json[:id]
    object.name = json[:name]
    object.shortName = json[:shortName]
    object.namespace = json[:namespace]
    return object
  end

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    return FieldValidation.valid_short_name?(:short_name, self.shortName, self) && FieldValidation.valid_long_name?(:name, self.name, self)
  end

end