require "nokogiri"
require "uri"

class RegistrationAuthority

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :number, :scheme, :namespace
  validates_presence_of :number, :scheme, :namespace
  
  # Base namespace 
  @@baseNs
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CLASS_RA_PREFIX = "RA"
  C_CLASS_RAI_PREFIX = "RAI"
  C_DUNS = "DUNS"
  C_CLASS_NAME = "RegistrationAuthority"
      
  #Class variables
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  @@owner = nil # The owner of the repository
  
  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def baseNs
    return @@baseNs 
  end
  
  def name
    return namespace.name
  end

  def shortName
    return namespace.shortName
  end

  def self.find(id)
    
    ra = nil
    
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
        ra.namespace = Namespace.find(ModelUtility.extractCid(siSet[0].text))
        ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + id)
        end
    end
    
    # Return
    return ra
    
  end

  def self.all
    
    results = Hash.new
    
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
        ra.namespace = Namespace.find(ModelUtility.extractCid(siSet[0].text))
        ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + ra.id)
        results[ra.id] = ra
      end
    end
    
    # Set owner. Assumed to be first authority.
    if @@owner == nil
      @@owner = results.values[0]
    end

    # Return
    return results
    
  end

  # Get the repository owner.
  def self.owner

    # The owner is assumed to be the first entry.
    if @@owner == nil
      results = self.all
    end
    return @@owner
    
  end

  def self.create(params)
    
    number = params[:number]
    namespaceId = params[:namespaceId]
    
    # Create the query
    raiId = ModelUtility.buildCid(C_CLASS_RAI_PREFIX, number)
    id = ModelUtility.buildCid(C_CLASS_RA_PREFIX, number)
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
      ConsoleLogger::log(C_CLASS_NAME,"create","Object created, id=" + id)
    else
      ConsoleLogger::log(C_CLASS_NAME,"create","Object not created!")
      ra = nil
      #object.assign_errors(data) if response.response_code == 422
    end
    return ra
    
  end

  def update(id)
    return nil
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

    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Object destroyed.")
    else
      ConsoleLogger::log(C_CLASS_NAME,"destroy","Object not destroyed!")
    end
     
  end
  
end