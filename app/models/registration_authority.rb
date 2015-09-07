require "nokogiri"

class RegistrationAuthority

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :number, :organization_id
  validates_presence_of :name, :number
  
  #self.primary_key = 'puri'
  
  C_NS = "http://www.assero.co.uk/MDROrganizations" 
  C_PREFIX = "org" + ": <" + C_NS + "#>"
  C_PREFIXES = ["isoR: <http://www.assero.co.uk/ISO11179Registration#>" , 
        "isoB: <http://www.assero.co.uk/ISO11179Basic#>" ,
        "isoI: <http://www.assero.co.uk/ISO11179Identification#>" ,
        "rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>" ,
        "rdfs: <http://www.w3.org/2000/01/rdf-schema#>" ,
        "xsd: <http://www.w3.org/2001/XMLSchema#>" ]
  C_RA_PREFIX = "RA"
  C_RAI_PREFIX = "RAI"
        
  def persisted?
    id.present?
  end
 
  def self.find(id)
    
    ra = nil
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "SELECT ?b ?c WHERE \n" +
      "{ \n" +
      "org:" + id + " isoR:registrationAuthorityIdentifierRelationship ?a . \n" +
      "	?a isoB:organizationIdentifier ?b . \n" +
      "	?a isoB:registrationAuthorityNamespaceRelationship ?c . \n" +
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
        ra.organization_id = ModelUtility.URIGetId(linkSet[0].text)

      end
    end
    
    # Return
    return ra
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "SELECT ?a ?c ?d WHERE \n" +
      "{ \n" +
      "	?a rdf:type isoR:RegistrationAuthority . \n" +
      "	?a isoR:registrationAuthorityIdentifierRelationship ?b . \n" +
      "	?b isoB:organizationIdentifier ?c . \n" +
      "	?b isoB:registrationAuthorityNamespaceRelationship ?d . \n" +
      #"	?d isoB:namingAuthorityRelationship ?e . \n" +
      #"	?e isoB:name ?f ; \n" +
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
        ra.id = ModelUtility.URIGetId(uriSet[0].text)
        ra.number = literalSet[0].text
        ra.organization_id = ModelUtility.URIGetId(linkSet[0].text)
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
    raiId = ModelUtility.BuildId(C_RAI_PREFIX, unique.to_s)
    id = ModelUtility.BuildId(C_RA_PREFIX, unique.to_s)
    update = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "INSERT DATA \n" +
      "{ \n" +
      "	org:" + raiId + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	org:" + raiId + " isoB:organizationIdentifier \"" + number.to_s + "\"^^xsd:string . \n" +
      "	org:" + raiId + " isoB:internationalCodeDesignator \"DUNS\"^^xsd:string . \n" +
      "	org:" + raiId + " isoB:registrationAuthorityNamespaceRelationship org:" + org.to_s + " . \n" +
      "	org:" + id + " rdf:type isoR:RegistrationAuthority . \n" +
      "	org:" + id + " isoR:registrationAuthorityIdentifierRelationship org:" + raiId + " ; \n" +
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
    unique = ModelUtility.URIGetUnique(self.id)
    raiId = ModelUtility.BuildId(C_RAI_PREFIX, unique)
    update = ModelUtility.BuildPrefixes(C_PREFIX, C_PREFIXES) +
      "DELETE DATA \n" +
      "{ \n" +
      "	org:" + raiId + " rdf:type isoB:RegistrationAuthorityIdentifier . \n" +
      "	org:" + raiId + " isoB:organizationIdentifier \"" + self.number.to_s + "\"^^xsd:string . \n" +
      "	org:" + raiId + " isoB:internationalCodeDesignator \"DUNS\"^^xsd:string . \n" +
      "	org:" + raiId + " isoB:registrationAuthorityNamespaceRelationship org:" + self.organization_id.to_s + " . \n" +
      "	org:" + self.id + " rdf:type isoR:RegistrationAuthority . \n" +
      "	org:" + self.id + " isoR:registrationAuthorityIdentifierRelationship org:" + raiId + " ; \n" +
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