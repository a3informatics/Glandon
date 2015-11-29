require "nokogiri"
require "uri"

class RegistrationState

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :registrationAuthority, :registrationStatus, :administrativeNote, :effectiveDate, :unresolvedIssue, :administrativeStatus, :previousState
  validates_presence_of :registrationAuthority, :registrationStatus, :administrativeNote, :effectiveDate, :unresolvedIssue, :administrativeStatus, :previousState
  
  # Base namespace 
  @@baseNs
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CID_PREFIX = "RS"
  C_CLASS_NAME = "RegistrationState"
  
  # Class varaibles
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  @@owner = RegistrationAuthority.owner()

  def persisted?
    id.present?
  end
 
  def initialize()
  end

  def baseNs
    return @@baseNs 
  end
  
  def registrationAuthority
    return @@owner
  end
  
  def self.find(id)
    
    object = nil
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a ?c ?d ?e ?f ?g ?h WHERE \n" +
      "{ \n" +
      "  :" + id + " rdf:type isoR:RegistrationState . \n" +
      "  :" + id + " isoR:byAuthority ?b . \n" +
      "  :" + id + " isoR:registrationStatus ?c . \n" +
      "  :" + id + " isoR:administrativeNote ?d . \n" +       
      "  :" + id + " isoR:effectiveDate ?e . \n" + 
      "  :" + id + " isoR:unresolvedIssue ?f . \n" +
      "  :" + id + " isoR:administrativeStatus ?g . \n" +   
      "  :" + id + " isoR:previousState ?h . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      raSet = node.xpath("binding[@name='b']/uri")
      rsSet = node.xpath("binding[@name='c']/literal")
      rnet = node.xpath("binding[@name='d']/literal")
      edSet = node.xpath("binding[@name='e']/literal")
      uiSet = node.xpath("binding[@name='f']/literal")
      asSet = node.xpath("binding[@name='g']/literal")
      psSet = node.xpath("binding[@name='h']/literal")
      if uriSet.length == 1 && raSet.length == 1 && rsSet.length == 1 && rnSet.length == 1 && edSet.length == 1 && uiSet.length == 1 && asSet.length == 1 && psSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.registrationAuthority_id = RegistrationAuthority.find(ModelUtility.extractCid(raSet[0].text))
        object.registrationStatus = oSet[0].text
        object.administrativeNote = sSet[0].text
        object.effectiveDate = snSet[0].text
        object.unresolvedIssue = lnSet[0].text
        object.administrativeStatus = lnSet[0].text
        object.previousState  = lnSet[0].text
      end
    end
    
    # Return
    return object
    
  end

  def self.all
    
    results = Array.new
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a ?c ?d ?e ?f ?g ?h WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type isoR:RegistrationState . \n" +
      "	 ?a isoR:registrationStatus ?c . \n" +
      "	 ?a isoR:administrativeNote ?d . \n" +       
      "	 ?a isoR:effectiveDate ?e . \n" + 
      "	 ?a isoR:unresolvedIssue ?f . \n" +
      "	 ?a isoR:administrativeStatus ?g . \n" +   
      "	 ?a isoR:previousState ?h . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.query(query)
    
    # Process the response
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      uriSet = node.xpath("binding[@name='a']/uri")
      rsSet = node.xpath("binding[@name='c']/literal")
      rnSet = node.xpath("binding[@name='d']/literal")
      edSet = node.xpath("binding[@name='e']/literal")
      uiSet = node.xpath("binding[@name='f']/literal")
      asSet = node.xpath("binding[@name='g']/literal")
      psSet = node.xpath("binding[@name='h']/literal")
      if uriSet.length == 1 && rsSet.length == 1 && rnSet.length == 1 && edSet.length == 1 && uiSet.length == 1 && asSet.length == 1 && psSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.registrationStatus = rsSet[0].text
        object.administrativeNote = rnSet[0].text
        object.effectiveDate = edSet[0].text
        object.unresolvedIssue = uiSet[0].text
        object.administrativeStatus = asSet[0].text
        object.previousState  = psSet[0].text
        results.push (object)
      end
    end
    
    return results
    
  end

  def self.create(params, uid)
    
    # Create the query
    id = ModelUtility.buildCidUid(C_CID_PREFIX, uid)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	:" + id + " rdf:type isoR:RegistrationState . \n" +
      "	:" + id + " isoR:byAuthority :" + @@owner.id + " . \n" +
      "	:" + id + " isoR:registrationStatus \"""\"^^xsd:string . \n" +
      "	:" + id + " isoR:administrativeNote \"""\"^^xsd:string . \n" +
      "	:" + id + " isoR:effectiveDate \"""\"^^xsd:string . \n" +
      "	:" + id + " isoR:unresolvedIssue \"""\"^^xsd:string . \n" +
      "	:" + id + " isoR:administrativeStatus \"""\"^^xsd:string . \n" +
      "	:" + id + " isoR:previousState \"""\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.registrationStatus = ""
      object.administrativeNote = ""
      object.effectiveDate = ""
      object.unresolvedIssue = ""
      object.administrativeStatus = ""
      object.previousState  = ""
      ConsoleLogger::log(C_CLASS_NAME,"create","Created Id=" + id.to_s)
    else
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed to create object")
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def update(id)
    return nil
  end

  def destroy
    return nil
  end
  
end