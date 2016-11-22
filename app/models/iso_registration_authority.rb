require "nokogiri"
require "uri"

class IsoRegistrationAuthority

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :number, :scheme, :namespace, :owner
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CLASS_RA_PREFIX = "RA"
  C_CLASS_RAI_PREFIX = "RAI"
  C_DUNS = "DUNS"
  C_CLASS_NAME = "IsoRegistrationAuthority"
      
  #Class variables
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  @@repositoryOwner = nil
  @@id_map = Hash.new
  @@name_map = Hash.new

  def persisted?
    id.present?
  end
 
  # Initialize
  #
  # @return [object] The initialized object
  def initialize()
    self.id = ""
    self.number = "<Not Set>"
    self.scheme = C_DUNS
    self.namespace = IsoNamespace.new
    self.owner = false
    @@baseNs ||= UriManagement.getNs(C_NS_PREFIX)
  end

  # Get the name
  #
  # @return [string] The authority name
  def name
    return namespace.name
  end

  # Get the short name
  #
  # @return [string] The authority short name
  def shortName
    return namespace.shortName
  end

  # Find if the authority with identifier number exists.
  #
  # @return [boolean] True if the item exists, False otherwise.
  def exists?
    result = false
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  ?b isoB:organizationIdentifier \"#{self.number}\" . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    return true if xmlDoc.xpath("//result").count > 0
    return false
  end

  # Find an authroity
  #
  # @param id [string] the id required.
  # @return [IsoRegistrationAuthority, nil] The authority if found, otherwise nil.
  def self.find(id)
    ra = self.new
    if @@id_map.has_key?(id)
      ra = @@id_map[id]
    else
      # Create the query
      query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
        "SELECT ?c ?d ?e ?f WHERE \n" +
        "{ \n" +
        "	 :" + id + " rdf:type isoR:RegistrationAuthority . \n" +
        "  :" + id + " isoR:hasAuthorityIdentifier ?b . \n" +
        "  :" + id + " isoR:raNamespace ?e . \n" +
        "  :" + id + " isoR:owner ?f . \n" +
        "	 ?b isoB:organizationIdentifier ?c . \n" +
        "	 ?b isoB:internationalCodeDesignator ?d . \n" +
        "}"
      # Send the request, wait the resonse
      response = CRUD.query(query)
      # Process the response
      xmlDoc = Nokogiri::XML(response.body)
      xmlDoc.remove_namespaces!
      xmlDoc.xpath("//result").each do |node|
        oSet = node.xpath("binding[@name='c']/literal")
        sSet = node.xpath("binding[@name='d']/literal")
        siSet = node.xpath("binding[@name='e']/uri")
        owner = ModelUtility.getValue('f', false, node).to_bool
        if oSet.length == 1 
          ra.id = id
          ra.number = oSet[0].text
          ra.scheme = sSet[0].text
          ra.owner = owner
          ra.namespace = IsoNamespace.find(ModelUtility.extractCid(siSet[0].text))
          @@id_map[ra.id] = ra
          @@name_map[ra.namespace.shortName] = ra
        end
      end
    end
    return ra
  end

  # Find an authroity by the short name
  #
  # @param short_name [string] The short name required.
  # @return [object] The authority
  def self.find_by_short_name(short_name)
    # Do we have a stored result
    object = self.new
    if @@name_map.has_key?(short_name)
      object = @@name_map[short_name]
    else
      results = self.all()
      object = @@name_map[short_name]
    end
    return object
  end

  # Find all the authorities
  #
  # @return [array] Array holding all the authority objects
  def self.all  
    results = Array.new
    @@id_map = Hash.new
    @@name_map = Hash.new
    @@repositoryOwner = nil
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a ?c ?d ?e ?f WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type isoR:RegistrationAuthority . \n" +
      "	 ?a isoR:hasAuthorityIdentifier ?b . \n" +
      "  ?a isoR:raNamespace ?e . \n" +
      "  ?a isoR:owner ?f . \n" +
      "	 ?b isoB:organizationIdentifier ?c . \n" +
      "	 ?b isoB:internationalCodeDesignator ?d . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.query(query)
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      oSet = node.xpath("binding[@name='c']/literal")
      sSet = node.xpath("binding[@name='d']/literal")
      siSet = node.xpath("binding[@name='e']/uri")
      owner = ModelUtility.getValue('f', false, node).to_bool
      if uriSet.length == 1
        ra = self.new 
        ra.id = ModelUtility.extractCid(uriSet[0].text)
        ra.number = oSet[0].text
        ra.scheme = sSet[0].text
        ra.owner = owner
        # Set owner. Only single allowed.
        if owner
          if @@repositoryOwner == nil
            @@repositoryOwner = ra
          else
            ConsoleLogger.info(C_CLASS_NAME, "all", "Multiple Registration Authority owners detected.")
            raise Exceptions::MultipleOwnerError.new(message: "Multiple Registration Authority owners detected.")
          end
        end
        ra.namespace = IsoNamespace.find(ModelUtility.extractCid(siSet[0].text))
        results << ra
        @@id_map[ra.id] = ra
        @@name_map[ra.namespace.shortName] = ra
      end
    end
    return results
  end

  # Find the owner of the repository
  #
  # @return [object] The object holding the authority that owns the repository
  def self.owner
    # The owner is assumed to be the first entry.
    if @@repositoryOwner == nil
      results = self.all
      @@repositoryOwner = self.new if @@repositoryOwner == nil
    end
    return @@repositoryOwner
  end

  # Create an authority
  #
  # @param params [hash] Hash holding {:number the authority DUNS number, :namespaceId the id of the namespace object}
  # @return [object] The object holding the authority that owns the repository
  def self.create(params)
    ra = self.new
    ra.namespace = IsoNamespace.find(params[:namespaceId])
    ra.number = params[:number]
    uid = ra.number
    if ra.valid?
      if !ra.exists?
        uri = UriV2.new({:namespace => @@baseNs, :prefix => C_CLASS_RA_PREFIX, :org_name => C_DUNS, :identifier => uid})  
        rai_uri = UriV2.new({:namespace => @@baseNs, :prefix => C_CLASS_RAI_PREFIX, :org_name => C_DUNS, :identifier => uid}) 
        ra.id = uri.id
        ConsoleLogger.debug(C_CLASS_NAME, "create", "RA=#{ra.to_json}")
        update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "	:" + rai_uri.id + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
          "	:" + rai_uri.id + " isoB:organizationIdentifier \"#{ra.number}\"^^xsd:string . \n" +
          "	:" + rai_uri.id + " isoB:internationalCodeDesignator \"#{ra.scheme}\"^^xsd:string . \n" +
          "	:" + uri.id + " rdf:type isoR:RegistrationAuthority . \n" +
          " :" + uri.id + " isoR:raNamespace :#{ra.namespace.id} . \n" +
          "	:" + uri.id + " isoR:hasAuthorityIdentifier :#{rai_uri.id} . \n" +
          " :" + uri.id + " isoR:owner \"#{ra.owner}\"^^xsd:boolean . \n" +
          "}"
        response = CRUD.update(update)
        if !response.success?
          ConsoleLogger.info(C_CLASS_NAME,"create", "Failed to create object.")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      else
        ra.errors.add(:base, "The registration authority already exists.")
      end
    end
    return ra
  end

  # Destroy an authority
  #
  # @return [null]
  # @raise [ExceptionClass] DestroyError if object not destroyed
  def destroy
    # Create the query
    rai_uri = IsoUtility.uri(@@baseNs, self.id)
    rai_uri.update_prefix(C_CLASS_RAI_PREFIX)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	:" + rai_uri.id + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	:" + rai_uri.id + " isoB:organizationIdentifier \"" + self.number.to_s + "\"^^xsd:string . \n" +
      "	:" + rai_uri.id + " isoB:internationalCodeDesignator \"DUNS\"^^xsd:string . \n" +
      "	:" + self.id + " rdf:type isoR:RegistrationAuthority . \n" +
      " :" + self.id + " isoR:raNamespace :" + self.namespace.id + " . \n" +
      "	:" + self.id + " isoR:hasAuthorityIdentifier :" + rai_uri.id + " . \n" +
      " :" + self.id + " isoR:owner \"#{self.owner}\"^^xsd:boolean . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Process the response
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  # To JSON
  #
  # @return [hash] The object hash 
  def to_json
    json = 
    { 
      :id => self.id, 
      :number => self.number,
      :scheme => self.scheme,
      :owner => self.owner,
      :namespace => self.namespace.to_json
    }
    return json
  end

  # From JSON
  #
  # @param json [hash] The hash of values for the object 
  # @return [object] The object
  def self.from_json(json)
    object = self.new
    #ConsoleLogger::log(C_CLASS_NAME,"from_json", "Json=#{json}")
    object.id = json[:id]
    object.number = json[:number]
    object.scheme = json[:scheme]
    object.owner = json[:owner]
    object.namespace = IsoNamespace.from_json(json[:namespace])
    return object
  end

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    namespace_valid = self.namespace.valid?
    if !namespace_valid
      self.namespace.errors.full_messages.each do |msg|
        self.errors[:base] << "Namespace error: #{msg}"
      end
    end
    return valid_duns? && valid_scheme? && namespace_valid
  end

private

  def valid_duns?
    if self.number.nil?
      self.errors.add(:number, "is empty.")
      return false
    else
      result = self.number.match /\A[0-9]{9}\z/ 
      return true if result != nil
      self.errors.add(:number, "does not contains 9 digits")
      return false
    end
  end

  def valid_scheme?
    if self.scheme == C_DUNS
      return true
    else
      self.errors.add(:scheme, "contains an invalid value")
      return false
    end
  end
  
end