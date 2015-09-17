require "nokogiri"
require "uri"

class RegistrationAuthority

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :number, :organization_id
  validates_presence_of :name, :number, :organization_id
  
  # Base namespace 
  @@ns
  
  # Constants
  C_NS_PREFIX = "org"
  C_CLASS_RA_PREFIX = "RA"
  C_CLASS_RAI_PREFIX = "RAI"
        
  def persisted?
    id.present?
  end
 
  def initialize()
    
    after_initialize
  
  end

  def ns
    
    return @@ns 
    
  end
  
  def name
    
    if self.organization_id == nil
      return ""
    else
      org = Organization.find(self.organization_id)
      return org.name
    end
    
  end
  
  def self.find(id)
    
    ra = nil
    
    # Create the query
    query = Namespace.build(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?b ?c WHERE \n" +
      "{ \n" +
      "  :" + id + " isoR:registrationAuthorityIdentifierRelationship ?a . \n" +
      "	 ?a isoB:organizationIdentifier ?b . \n" +
      "	 ?a isoB:registrationAuthorityNamespaceRelationship ?c . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      literalSet = node.xpath("binding[@name='b']/literal")
      linkSet = node.xpath("binding[@name='c']/uri")
      
      p "Literal: " + literalSet.text
      p "Link: " + linkSet.text

      if literalSet.length == 1 and linkSet.length == 1

        p "Found: " + literalSet[0].text

        ra = self.new 
        ra.id = id
        ra.number = literalSet[0].text
        ra.organization_id = ModelUtility.extractCid(linkSet[0].text)

      end
    end
    
    # Return
    return ra
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = Namespace.build(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a ?c ?d WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type isoR:RegistrationAuthority . \n" +
      "	 ?a isoR:registrationAuthorityIdentifierRelationship ?b . \n" +
      "	 ?b isoB:organizationIdentifier ?c . \n" +
      "	 ?b isoB:registrationAuthorityNamespaceRelationship ?d . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      
      p "Node: " + node.text
      
      literalSet = node.xpath("binding[@name='c']/literal")
      uriSet = node.xpath("binding[@name='a']/uri")
      linkSet = node.xpath("binding[@name='d']/uri")
      
      p "Literal: " + literalSet.text
      p "URI: " + uriSet.text
      p "Link: " + linkSet.text

      if uriSet.length == 1 and literalSet.length == 1 and linkSet.length == 1

        p "Found: " + literalSet[0].text

        ra = self.new 
        ra.id = ModelUtility.extractCid(uriSet[0].text)
        ra.number = literalSet[0].text
        ra.organization_id = ModelUtility.extractCid(linkSet[0].text)
        results.push (ra)
      end
    end
    
    return results
    
  end

  def self.create(params)
    
    number = params[:number]
    org = params[:organization_id]
    unique = number.to_s.parameterize
    
    p "Org=" + org.to_s
    
    # Create the query
    raiId = ModelUtility.buildCid(C_CLASS_RAI_PREFIX, unique.to_s)
    id = ModelUtility.buildCid(C_CLASS_RA_PREFIX, unique.to_s)
    update = Namespace.build(C_NS_PREFIX, ["isoB", "isoR"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	:" + raiId + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	:" + raiId + " isoB:organizationIdentifier \"" + number.to_s + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:internationalCodeDesignator \"DUNS\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:registrationAuthorityNamespaceRelationship :" + org.to_s + " . \n" +
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
      ra.organization_id = org
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
    update = Namespace.build(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE DATA \n" +
      "{ \n" +
      "	:" + raiId + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	:" + raiId + " isoB:organizationIdentifier \"" + self.number.to_s + "\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:internationalCodeDesignator \"DUNS\"^^xsd:string . \n" +
      "	:" + raiId + " isoB:registrationAuthorityNamespaceRelationship :" + self.organization_id.to_s + " . \n" +
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
  
  private
  
  def after_initialize
  
    @@ns = Namespace.find(C_NS_PREFIX)
  
  end
  
end