require "nokogiri"
require "uri"

class IsoRegistrationState

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :registrationAuthority, :registrationStatus, :administrativeNote, :effectiveDate, :unresolvedIssue, :administrativeStatus, :previousState
  validates_presence_of :registrationAuthority, :registrationStatus, :administrativeNote, :effectiveDate, :unresolvedIssue, :administrativeStatus, :previousState
  
  # Base namespace 
  @@baseNs

  C_NOTSET = ""
  C_INCOMPLETE = "Incomplete"
  C_CANDIDATE =  "Candidate"
  C_RECORDED = "Recorded"
  C_QUALIFIED = "Qualified"
  C_STANDARD = "Standard"
  C_RETIRED = "Retired"
  C_SUPERSEDED = "Superseded"

  @@stateInfo = {
    C_NOTSET => 
      { 
        :key => C_NOTSET, 
        :label => "Not set", 
        :definition => "State has not beeen set",
        :delete_enabled => false, 
        :edit_enabled => true, 
        :edit_up_version => true, # New items set to this state 
        :state_on_edit => C_INCOMPLETE,
        :next_state => C_INCOMPLETE
      },
    C_INCOMPLETE  => 
      { 
        :key => C_INCOMPLETE, 
        :label => "Incomplete", 
        :definition => "Submitter wishes to make the community that uses this metadata register aware of the existence of an Administered Item in their local domain.",        
        :delete_enabled => true, 
        :edit_enabled  => true,
        :edit_up_version => false,
        :state_on_edit => C_INCOMPLETE,
        :next_state => C_CANDIDATE
      },
    C_CANDIDATE =>
      { 
        :key => C_CANDIDATE, 
        :label => "Candidate", 
        :definition => "The Administered Item has been proposed for progression through the registration levels.",
        :delete_enabled => false, 
        :edit_enabled  => true,
        :edit_up_version => false,
        :state_on_edit => C_CANDIDATE,
        :next_state => C_RECORDED
      },
    C_RECORDED =>
      { 
        :key => C_RECORDED, 
        :label => "Recorded", 
        :definition => "The Registration Authority has confirmed that: a) all mandatory metadata attributes have been completed.",
        :delete_enabled => false, 
        :edit_enabled  => true,
        :edit_up_version => true,
        :state_on_edit => C_RECORDED,
        :next_state => C_QUALIFIED
      },
    C_QUALIFIED =>
      { 
        :key => C_QUALIFIED, 
        :label => "Qualified", 
        :definition => "The Registration Authority has confirmed that: a) the mandatory metadata attributes are complete and b) the mandatory metadata attributes conform to applicable quality requirements.",
        :delete_enabled => false, 
        :edit_enabled  => true,
        :edit_up_version => true,
        :state_on_edit => C_QUALIFIED,
        :next_state => C_STANDARD
      },
    C_STANDARD =>
      { 
        :key => C_STANDARD, 
        :label => "Standard", 
        :definition => "The Registration Authority confirms that the Administered Item is: a) of sufficient quality and b) of broad interest for use in the community that uses this metadata register.",
        :delete_enabled => false, 
        :edit_enabled  => true,
        :edit_up_version => true,
        :state_on_edit => C_INCOMPLETE,
        :next_state => C_SUPERSEDED
      },
    C_RETIRED =>
      { 
        :key => C_RETIRED, 
        :label => "Retired", 
        :definition => "The Registration Authority has approved the Administered Item as: a) no longer recommended for use in the community that uses this metadata register and b) should no longer be used.",
        :delete_enabled => false, 
        :edit_enabled  => false,
        :edit_up_version => false,
        :state_on_edit => C_RETIRED,
        :next_state => C_RETIRED
      },
    C_SUPERSEDED =>
      { 
        :key => C_SUPERSEDED, 
        :label => "Superseded", 
        :definition => "The Registration Authority determined that the Administered Item is: a) no longer recommended for use by the community that uses this metadata register, and b) a successor Administered Item is now preferred for use.",
        :delete_enabled => false, 
        :edit_enabled => false, 
        :edit_up_version => false, 
        :state_on_edit => C_SUPERSEDED,
        :next_state => C_SUPERSEDED
      }
  }

  # Edit control
  @@edit_control = {
    
  }  

  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CID_PREFIX = "RS"
  C_CLASS_NAME = "IsoRegistrationState"
  
  # Class varaibles
  @@baseNs = UriManagement.getNs(C_NS_PREFIX)
  @@owner = IsoRegistrationAuthority.owner()

  def persisted?
    id.present?
  end
 
  def initialize()
    self.id = ""
    self.registrationAuthority = nil
    self.registrationStatus = C_NOTSET
    self.administrativeNote = ""
    self.effectiveDate = Time.now
    self.unresolvedIssue = ""
    self.administrativeStatus = ""
    self.previousState  = C_NOTSET
    if @@owner == nil # Temp fix, not getting set in circumstances. Needs better fix.
      @@owner = IsoRegistrationAuthority.owner()
    end
  end

  def baseNs
    return @@baseNs 
  end
  
  def registrationAuthority
    return @@owner
  end
  
  def self.nextState(state)
    info = @@stateInfo[state]
    nextState = info[:next_state]
    ConsoleLogger::log(C_CLASS_NAME,"nextState","Old=" + state.to_s + ", New=" + nextState)
    return nextState
  end

  def self.stateLabel(state)
    info = @@stateInfo[state]
    return info[:label]
  end

  def self.stateDefinition(state)
    info = @@stateInfo[state]
    return info[:definition]
  end

  def self.releasedState
    return C_STANDARD
  end
  
  def edit?()
    info = @@stateInfo[self.registrationStatus]
    return info[:edit_enabled]
  end

  def delete?()
    info = @@stateInfo[self.registrationStatus]
    return info[:delete_enabled]
  end

  def state_on_edit()
    info = @@stateInfo[self.registrationStatus]
    return info[:state_on_edit]
  end

  def new_version?()
    info = @@stateInfo[self.registrationStatus]
    return info[:edit_up_version]
  end

  def self.find(id)
    
    #ConsoleLogger::log(C_CLASS_NAME,"find","*****Entry*****")
    object = nil
    
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?b ?c ?d ?e ?f ?g ?h WHERE \n" +
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
      #ConsoleLogger::log(C_CLASS_NAME,"find","Node=" + node.to_s)
      raSet = node.xpath("binding[@name='b']/uri")
      rsSet = node.xpath("binding[@name='c']/literal")
      anSet = node.xpath("binding[@name='d']/literal")
      edSet = node.xpath("binding[@name='e']/literal")
      uiSet = node.xpath("binding[@name='f']/literal")
      asSet = node.xpath("binding[@name='g']/literal")
      psSet = node.xpath("binding[@name='h']/literal")
      if raSet.length == 1 && rsSet.length == 1 && anSet.length == 1 && edSet.length == 1 && uiSet.length == 1 && asSet.length == 1 && psSet.length == 1
        object = self.new 
        object.id = id
        object.registrationAuthority = IsoRegistrationAuthority.find(ModelUtility.extractCid(raSet[0].text))
        object.registrationStatus = rsSet[0].text
        object.administrativeNote = anSet[0].text
        object.effectiveDate = edSet[0].text
        object.unresolvedIssue = uiSet[0].text
        object.administrativeStatus = asSet[0].text
        object.previousState  = psSet[0].text
        #ConsoleLogger::log(C_CLASS_NAME,"find","Object created, id=" + object.id)
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

  def self.create(identifier, version, scope_org)
    
    # Create the query
    id = ModelUtility.build_full_cid(C_CID_PREFIX , scope_org.shortName, identifier, version)
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "INSERT DATA \n" +
      "{ \n" +
      "	:" + id + " rdf:type isoR:RegistrationState . \n" +
      "	:" + id + " isoR:byAuthority :" + @@owner.id + " . \n" +
      "	:" + id + " isoR:registrationStatus \"" + C_INCOMPLETE + "\"^^xsd:string . \n" +
      "	:" + id + " isoR:administrativeNote \"\"^^xsd:string . \n" +
      "	:" + id + " isoR:effectiveDate \"\"^^xsd:string . \n" +
      "	:" + id + " isoR:unresolvedIssue \"\"^^xsd:string . \n" +
      "	:" + id + " isoR:administrativeStatus \"\"^^xsd:string . \n" +
      "	:" + id + " isoR:previousState \"" + C_INCOMPLETE + "\"^^xsd:string . \n" +
      "}"
    
    # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      object = self.new
      object.id = id
      object.registrationStatus = C_INCOMPLETE
      object.administrativeNote = ""
      object.effectiveDate = ""
      object.unresolvedIssue = ""
      object.administrativeStatus = ""
      object.previousState  = C_INCOMPLETE 
      #ConsoleLogger::log(C_CLASS_NAME,"create","Created Id=" + id.to_s)
    else
      #ConsoleLogger::log(C_CLASS_NAME,"create","Failed to create object")
      object = self.new
      object.assign_errors(data) if response.response_code == 422
    end
    return object
    
  end

  def self.create_dummy(identifier, version, scope_org)
    object = self.new
    object.id = ModelUtility.build_full_cid(C_CID_PREFIX , scope_org.shortName, identifier, version)
    object.registrationStatus = C_INCOMPLETE
    object.administrativeNote = ""
    object.effectiveDate = ""
    object.unresolvedIssue = ""
    object.administrativeStatus = ""
    object.previousState  = C_INCOMPLETE 
    return object
  end

  def self.create_sparql(identifier, version, scope_org, sparql)
    id = ModelUtility.build_full_cid(C_CID_PREFIX , scope_org.shortName, identifier, version)
    sparql.add_prefix("isoR")
    sparql.add_prefix("isoI")
    sparql.triple(C_NS_PREFIX, id, "rdf", "type", "isoR", "RegistrationState")
    sparql.triple(C_NS_PREFIX, id, "isoR", "byAuthority", C_NS_PREFIX, @@owner.id)
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoR", "registrationStatus", C_INCOMPLETE, "string")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoR", "administrativeNote", "", "string")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoR", "effectiveDate", "", "string")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoR", "unresolvedIssue", "", "string")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoR", "administrativeStatus", "", "string")
    sparql.triple_primitive_type(C_NS_PREFIX, id, "isoR", "previousState", C_INCOMPLETE, "string")
  end
  
  def self.count
    results = Hash.new
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoR"]) +
      "SELECT ?s (COUNT(?s) as ?c ) WHERE \n" +
      "{\n" +
      "  ?a isoR:registrationStatus ?s . \n" +
      "} GROUP BY ?s"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    xmlDoc.xpath("//result").each do |node|
      status = node.xpath("binding[@name='s']/literal")
      count = node.xpath("binding[@name='c']/literal")
      if status.length == 1
        results[status[0].text] = count[0].text
      end
    end
    return results
  end

  def update(id, params)
    
    registrationStatus = params[:registrationStatus]
    previousState  = params[:previousState]
    note = params[:administrativeNote]
    issue = params[:unresolvedIssue]
    date = params[:effectiveDate]
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + id + " isoR:registrationStatus ?a . \n" +
      " :" + id + " isoR:administrativeNote ?b . \n" +
      " :" + id + " isoR:effectiveDate ?c . \n" +
      " :" + id + " isoR:unresolvedIssue ?d . \n" +
      " :" + id + " isoR:previousState ?e . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " :" + id + " isoR:registrationStatus \"" + registrationStatus + "\"^^xsd:string . \n" +
      " :" + id + " isoR:administrativeNote \"" + note + "\"^^xsd:string . \n" +
      " :" + id + " isoR:effectiveDate \"" + date + "\"^^xsd:date . \n" +
      " :" + id + " isoR:unresolvedIssue \"" + issue + "\"^^xsd:string . \n" +
      " :" + id + " isoR:previousState \"" + previousState + "\"^^xsd:string . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + id + " isoR:registrationStatus ?a . \n" +
      " :" + id + " isoR:administrativeNote ?b . \n" +
      " :" + id + " isoR:effectiveDate ?c . \n" +
      " :" + id + " isoR:unresolvedIssue ?d . \n" +
      " :" + id + " isoR:previousState ?e . \n" +
      "}"

      # Send the request, wait the resonse
    response = CRUD.update(update)
    
    # Response
    if response.success?
      ConsoleLogger::log(C_CLASS_NAME,"create","Created Id=" + id.to_s)
    else
      ConsoleLogger::log(C_CLASS_NAME,"create","Failed to create object")
      #ßobject.assign_errors(data) if response.response_code == 422
    end

  end
  
end