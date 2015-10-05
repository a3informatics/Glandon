require "nokogiri"
require "uri"

class RegistrationAuthority

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :number, :shortName, :name, :scheme
  validates_presence_of :number, :shortName, :name, :scheme
  
  # Base namespace 
  @@baseNs
  
  # Constants
  C_NS_PREFIX = "org"
  C_CLASS_RA_PREFIX = "RA"
  C_CLASS_RAI_PREFIX = "RAI"
  DUNS = "DUNS"
  
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
    
    ra = nil
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?c ?d ?e ?f WHERE \n" +
      "{ \n" +
      "	 :" + id + " rdf:type isoR:RegistrationAuthority . \n" +
      "  :" + id + " isoR:registrationAuthorityIdentifierRelationship ?b . \n" +
      "	 ?b isoB:organizationIdentifier ?c . \n" +
      "	 ?b isoB:internationalCodeDesignator ?d . \n" +
      "	 ?b isoB:shortName ?e . \n" +
      "	 ?b isoB:name ?f . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      oSet = node.xpath("binding[@name='c']/literal")
      sSet = node.xpath("binding[@name='d']/literal")
      snSet = node.xpath("binding[@name='e']/literal")
      lnSet = node.xpath("binding[@name='f']/literal")
      if oSet.length == 1 && sSet.length == 1 && lnSet.length == 1 && snSet.length == 1
        ra = self.new 
        ra.id = id
        ra.number = oSet[0].text
        ra.scheme = sSet[0].text
        ra.shortName = snSet[0].text
        ra.name = lnSet[0].text
      end
    end
    
    # Return
    return ra
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a ?c ?d ?e ?f WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type isoR:RegistrationAuthority . \n" +
      "	 ?a isoR:registrationAuthorityIdentifierRelationship ?b . \n" +
      "	 ?b isoB:organizationIdentifier ?c . \n" +
      "	 ?b isoB:internationalCodeDesignator ?d . \n" +
      "	 ?b isoB:shortName ?e . \n" +
      "	 ?b isoB:name ?f . \n" +
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
      snSet = node.xpath("binding[@name='e']/literal")
      lnSet = node.xpath("binding[@name='f']/literal")
      if uriSet.length == 1 && oSet.length == 1 && sSet.length == 1 && lnSet.length == 1 && snSet.length == 1
        ra = self.new 
        ra.id = ModelUtility.extractCid(uriSet[0].text)
        ra.number = oSet[0].text
        ra.scheme = sSet[0].text
        ra.shortName = snSet[0].text
        ra.name = lnSet[0].text
        results.push (ra)
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    number = params[:number]
    #org = params[:organization_id]
    shortName = params[:shortName]
    longName = params[:name]
    
    # Create the query
    raiId = ModelUtility.buildCid(C_CLASS_RAI_PREFIX, number)
    id = ModelUtility.buildCid(C_CLASS_RA_PREFIX, number)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	:" + raiId + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	:" + raiId + " isoB:organizationIdentifier \"" + number.to_s + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:internationalCodeDesignator \"" + DUNS + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:shortName \"" + shortName.to_s + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:name \"" + longName.to_s + "\"^^xsd:string . \n" +
      "	:" + id + " rdf:type isoR:RegistrationAuthority . \n" +
      "	:" + id + " isoR:registrationAuthorityIdentifierRelationship :" + raiId + " ; \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      ra = self.new
      ra.id = id
      ra.number = number
      ra.scheme = DUNS
      ra.shortName = shortName
      ra.name = longName
      p "It worked!"
    else
      p "It didn't work!"
      ra = self.new
      object.assign_errors(data) if response.response_code == 422
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
      "	:" + raiId + " isoB:shortName \"" + self.shortName.to_s + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:name \"" + self.name.to_s + "\"^^xsd:string . \n" +
      "	:" + self.id + " rdf:type isoR:RegistrationAuthority . \n" +
      "	:" + self.id + " isoR:registrationAuthorityIdentifierRelationship :" + raiId + " ; \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)

    # Response
    if response.success?
      p "It worked!"
    else
      p "It didn't work!"
    end
     
  end
  
end