require "nokogiri"
require "uri"

class IsoRegistrationAuthority

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :number, :scheme, :namespace
  validates_presence_of :number, :scheme, :namespace
  
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
 
  def initialize()
    #@@repositoryOwner = nil
    #@@id_map = Hash.new
    #@@name_map = Hash.new
    @@baseNs ||= UriManagement.getNs(C_NS_PREFIX)
  end

  def name
    return namespace.name
  end

  def shortName
    return namespace.shortName
  end

  def self.find(id)
    ra = nil
    if @@id_map.has_key?(id)
      ra = @@id_map[id]
    else
      # Create the query
      query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
        "SELECT ?c ?d ?e WHERE \n" +
        "{ \n" +
        "	 :" + id + " rdf:type isoR:RegistrationAuthority . \n" +
        "  :" + id + " isoR:hasAuthorityIdentifier ?b . \n" +
        "  :" + id + " isoR:raNamespace ?e . \n" +
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
        if oSet.length == 1 && sSet.length == 1 && siSet.length == 1
          ra = self.new 
          ra.id = id
          ra.number = oSet[0].text
          ra.scheme = sSet[0].text
          ra.namespace = IsoNamespace.find(ModelUtility.extractCid(siSet[0].text))
          @@id_map[ra.id] = ra
          @@name_map[ra.namespace.shortName] = ra
        end
      end
    end
    return ra
  end

  # Find namespace by the short name.
  #
  # TODO: Better return for not found (will just be empty at the moment)
  #
  # * *Args*    :
  #   - +short_name+ -> The short name of the authority to be found
  # * *Returns* :
  #   - Registration Authority object
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

  def self.all  
    results = Hash.new
    @@id_map = Hash.new
    @@name_map = Hash.new
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a ?c ?d ?e WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type isoR:RegistrationAuthority . \n" +
      "	 ?a isoR:hasAuthorityIdentifier ?b . \n" +
      "  ?a isoR:raNamespace ?e . \n" +
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
      if uriSet.length == 1 && oSet.length == 1 && sSet.length == 1 && siSet.length == 1
        ra = self.new 
        ra.id = ModelUtility.extractCid(uriSet[0].text)
        ra.number = oSet[0].text
        ra.scheme = sSet[0].text
        ra.namespace = IsoNamespace.find(ModelUtility.extractCid(siSet[0].text))
        results[ra.id] = ra
        @@id_map[ra.id] = ra
        @@name_map[ra.namespace.shortName] = ra
      end
    end
    # Set owner. Assumed to be first authority.
    if @@repositoryOwner == nil
      @@repositoryOwner = results.values[0]
    end
    # Return
    return results
  end

  # Get the repository owner.
  def self.owner
    # The owner is assumed to be the first entry.
    if @@repositoryOwner == nil
      results = self.all
    end
    return @@repositoryOwner
  end

  def self.create(params)
    number = params[:number]
    namespaceId = params[:namespaceId]
    uid = number
    # Create the query
    raiId = ModelUtility.buildCidIdentifier(C_CLASS_RAI_PREFIX, uid)
    id = ModelUtility.buildCidIdentifier(C_CLASS_RA_PREFIX, uid)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	:" + raiId + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	:" + raiId + " isoB:organizationIdentifier \"" + number.to_s + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:internationalCodeDesignator \"" + C_DUNS + "\"^^xsd:string . \n" +
      "	:" + id + " rdf:type isoR:RegistrationAuthority . \n" +
      " :" + id + " isoR:raNamespace :" + namespaceId + " . \n" +
      "	:" + id + " isoR:hasAuthorityIdentifier :" + raiId + " ; \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if response.success?
      ra = self.new
      ra.id = id
      ra.number = number
      ra.scheme = C_DUNS
    else
      ConsoleLogger::log(C_CLASS_NAME,"create", "Failed to create object.")
      raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
    end
    return ra
  end

  def destroy
    # Create the query
    raiId = ModelUtility.cidSwapPrefix(self.id,C_CLASS_RAI_PREFIX)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	:" + raiId + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	:" + raiId + " isoB:organizationIdentifier \"" + self.number.to_s + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:internationalCodeDesignator \"DUNS\"^^xsd:string . \n" +
      "	:" + self.id + " rdf:type isoR:RegistrationAuthority . \n" +
      " :" + self.id + " isoR:raNamespace :" + self.namespace.id + " . \n" +
      "	:" + self.id + " isoR:hasAuthorityIdentifier :" + raiId + " ; \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Process the response
    if !response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy", "Failed to destroy object.")
      raise Exceptions::DestroyError.new(message: "Failed to destroy " + C_CLASS_NAME + " object.")
    end
  end

  def to_json
    json = 
    { 
      :id => self.id, 
      :number => self.number,
      :scheme => self.scheme,
      :namespace => self.namespace.to_json
    }
    return json
  end

  def self.from_json(json)
    object = self.new
    ConsoleLogger::log(C_CLASS_NAME,"from_json", "Json=#{json}")
    object.id = json[:id]
    object.number = json[:number]
    object.scheme = json[:scheme]
    object.namespace = IsoNamespace.from_json(json[:namespace])
    return object
  end
  
end