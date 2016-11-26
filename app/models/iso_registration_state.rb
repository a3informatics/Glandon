require "nokogiri"
require "uri"

class IsoRegistrationState

  include CRUD
  include ModelUtility
  include ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
      
  attr_accessor :id, :registrationAuthority, :registrationStatus, :administrativeNote, :effective_date, :until_date, :current, :unresolvedIssue , :administrativeStatus, :previousState
  
  # Constants
  C_NS_PREFIX = "mdrItems"
  C_CID_PREFIX = "RS"
  C_CLASS_NAME = "IsoRegistrationState"
  C_INSTANCE_NS = UriManagement.getNs(C_NS_PREFIX)

  C_NOTSET = ""
  C_INCOMPLETE = "Incomplete"
  C_CANDIDATE =  "Candidate"
  C_RECORDED = "Recorded"
  C_QUALIFIED = "Qualified"
  C_STANDARD = "Standard"
  C_RETIRED = "Retired"
  C_SUPERSEDED = "Superseded"

  C_DEFAULT_DATETIME = "2016-01-01T00:00:00+00:00"
  C_UNTIL_DATETIME = "2100-01-01T00:00:00+00:00"

  # Class variables
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
        :can_be_current => false, 
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
        :can_be_current => false, 
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
        :can_be_current => false, 
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
        :can_be_current => false, 
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
        :can_be_current => false, 
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
        :can_be_current => true, 
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
        :can_be_current => false, 
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
        :can_be_current => false, 
        :next_state => C_SUPERSEDED
      }
  }
  @@base_namespace

  def persisted?
    id.present?
  end
 
  # Initialize the object (new)
  # 
  # @param triples [hash] Hash of triples
  # @return [string] The owner's short name
  def initialize(triples=nil)
    @@base_namespace ||= UriManagement.getNs(C_NS_PREFIX)
    @@owner ||= IsoRegistrationAuthority.owner()
    date_time = Time.now
    if triples.nil?
      self.id = ""
      self.registrationAuthority = IsoRegistrationAuthority.new
      self.registrationStatus = C_NOTSET
      self.administrativeNote = ""
      self.effective_date = Time.parse(C_DEFAULT_DATETIME)
      self.until_date = Time.parse(C_DEFAULT_DATETIME)
      self.unresolvedIssue = ""
      self.administrativeStatus = ""
      self.previousState  = C_NOTSET
      self.current = false
    else
      self.id = ModelUtility.extractCid(triples[0][:subject])
      self.registrationAuthority = nil
      if Triples.link_exists?(triples, UriManagement::C_ISO_R, "byAuthority")
        links = Triples.get_links(triples, UriManagement::C_ISO_R, "byAuthority")
        cid = ModelUtility.extractCid(links[0])
        self.registrationAuthority  = IsoRegistrationAuthority.find(cid)
      end
      self.registrationStatus = Triples.get_property_value(triples, UriManagement::C_ISO_R, "registrationStatus")
      self.administrativeNote = Triples.get_property_value(triples, UriManagement::C_ISO_R, "administrativeNote")
      #temp_effective_date = Triples.get_property_value(triples, UriManagement::C_ISO_R, "effectiveDate")
      #temp_until_date = Triples.get_property_value(triples, UriManagement::C_ISO_R, "untilDate")
      #set_current_datetimes(temp_effective_date, temp_until_date)
      self.effective_date = Triples.get_property_value(triples, UriManagement::C_ISO_R, "effectiveDate").to_time_with_default
      self.until_date = Triples.get_property_value(triples, UriManagement::C_ISO_R, "untilDate").to_time_with_default
      self.unresolvedIssue = Triples.get_property_value(triples, UriManagement::C_ISO_R, "unresolvedIssue")
      self.administrativeStatus = Triples.get_property_value(triples, UriManagement::C_ISO_R, "administrativeStatus")
      self.previousState  = Triples.get_property_value(triples, UriManagement::C_ISO_R, "previousState")
      self.current = false
    end
    if date_time >= self.effective_date && date_time <= self.until_date
      self.current = true
    end
  end

  # Test if registered
  # 
  # @return [boolean] True if a registration state present
  def registered?()
    return self.registrationStatus != C_NOTSET
  end

  # Get the No State status
  # 
  # @return [string] The no state string
  def self.no_state()
    return C_NOTSET
  end

  # Get the next state
  # 
  # @param state [string] The current state
  # @return [string] The next state
  def self.nextState(state)
    info = @@stateInfo[state]
    nextState = info[:next_state]
    #ConsoleLogger::log(C_CLASS_NAME,"nextState","Old=" + state.to_s + ", New=" + nextState)
    return nextState
  end

  # Get the human readable label for a state
  #
  # @return [string] The label
  def self.stateLabel(state)
    info = @@stateInfo[state]
    return info[:label]
  end

  # Get the definition for a state
  #
  # @return [string] The definition
  def self.stateDefinition(state)
    info = @@stateInfo[state]
    return info[:definition]
  end

  # Get the released state
  #
  # @return [string] The released state
  def self.releasedState
    return C_STANDARD
  end
  
  # Is the item at the released state
  #
  # @return [boolean] True if in the released state, false otherwise
  def released_state?
    self.registrationStatus == C_STANDARD
  end
  
  # Can the item be edited
  #
  # @return [string] The next state
  def edit?
    info = @@stateInfo[self.registrationStatus]
    return info[:edit_enabled]
  end

  # Can the item be deleted
  #
  # @return [string] The next state
  def delete?
    info = @@stateInfo[self.registrationStatus]
    return info[:delete_enabled]
  end

  # Returns the new state after the item has been edited
  #
  # @return [string] The next state
  def state_on_edit
    info = @@stateInfo[self.registrationStatus]
    return info[:state_on_edit]
  end

  # Returns true if the version needs to be updated after an edit
  #
  # @return [string] The next state
  def new_version?
    info = @@stateInfo[self.registrationStatus]
    return info[:edit_up_version]
  end

  # Returns true if the item can be the current item
  #
  # @return [string] The next state
  def can_be_current?
    info = @@stateInfo[self.registrationStatus]
    return info[:can_be_current]
  end

  # Returns true if the state can be changed
  #
  # @return [string] The next state
  def can_be_changed?
    info = @@stateInfo[self.registrationStatus]
    return info[:next_state] != self.registrationStatus
  end

  # Find if the object with id exists.
  #
  # @return [boolean] True if the item exists, False otherwise.
  def exists?
    result = false
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoI", "isoB"]) +
      "SELECT ?a WHERE \n" +
      "{\n" +
      "  :#{self.id} rdf:type ?a . \n" +
      "}"
    response = CRUD.query(query)
    xmlDoc = Nokogiri::XML(response.body)
    xmlDoc.remove_namespaces!
    return true if xmlDoc.xpath("//result").count > 0
    return false
  end

  # Find the item gievn the id
  #
  # @param id [String] The id to be found
  # @return [Object, nil] The object if found, nil otherwise
  def self.find(id)
    object = self.new
    date_time = Time.now
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?b ?c ?d ?e ?f ?g ?h ?i WHERE \n" +
      "{ \n" +
      "  :" + id + " rdf:type isoR:RegistrationState . \n" +
      "  :" + id + " isoR:byAuthority ?b . \n" +
      "  :" + id + " isoR:registrationStatus ?c . \n" +
      "  :" + id + " isoR:administrativeNote ?d . \n" +       
      "  :" + id + " isoR:effectiveDate ?e . \n" + 
      "  :" + id + " isoR:untilDate ?i . \n" + 
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
      unSet = node.xpath("binding[@name='i']/literal")
      uiSet = node.xpath("binding[@name='f']/literal")
      asSet = node.xpath("binding[@name='g']/literal")
      psSet = node.xpath("binding[@name='h']/literal")
      if raSet.length == 1 # && rsSet.length == 1 && anSet.length == 1 && edSet.length == 1 && uiSet.length == 1 && asSet.length == 1 && psSet.length == 1
        object.id = id
        object.registrationAuthority = IsoRegistrationAuthority.find(ModelUtility.extractCid(raSet[0].text))
        object.registrationStatus = rsSet[0].text
        object.administrativeNote = anSet[0].text
        #object.set_current_datetimes(edSet[0].text, unSet[0].text)
        object.effective_date = edSet[0].text.to_time_with_default
        object.until_date = unSet[0].text.to_time_with_default
        object.unresolvedIssue = uiSet[0].text
        object.administrativeStatus = asSet[0].text
        object.previousState  = psSet[0].text
        # Determine if current
        if date_time >= object.effective_date && date_time <= object.until_date
            object.current = true
        end
      end
    end
    return object
  end

  # Find all items
  #
  # @return [Array] An array of objects.
  def self.all
    results = Array.new
    date_time = Time.now
    # Create the query
    query = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "SELECT ?a ?c ?d ?e ?f ?g ?h ?i WHERE \n" +
      "{ \n" +
      "	 ?a rdf:type isoR:RegistrationState . \n" +
      "	 ?a isoR:registrationStatus ?c . \n" +
      "	 ?a isoR:administrativeNote ?d . \n" +       
      "	 ?a isoR:effectiveDate ?e . \n" + 
      "  ?a isoR:untilDate ?i . \n" + 
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
      unSet = node.xpath("binding[@name='i']/literal")
      uiSet = node.xpath("binding[@name='f']/literal")
      asSet = node.xpath("binding[@name='g']/literal")
      psSet = node.xpath("binding[@name='h']/literal")
      if uriSet.length == 1 # && rsSet.length == 1 && rnSet.length == 1 && edSet.length == 1 && uiSet.length == 1 && asSet.length == 1 && psSet.length == 1
        object = self.new 
        object.id = ModelUtility.extractCid(uriSet[0].text)
        object.registrationStatus = rsSet[0].text
        object.administrativeNote = rnSet[0].text
        #object.set_current_datetimes(edSet[0].text, unSet[0].text)
        object.effective_date = edSet[0].text.to_time_with_default
        object.until_date = unSet[0].text.to_time_with_default
        object.unresolvedIssue = uiSet[0].text
        object.administrativeStatus = asSet[0].text
        object.previousState  = psSet[0].text
        # Determine if current
        if date_time >= object.effective_date && date_time <= object.until_date
            object.current = true
        end
        results.push (object)
      end
    end
    return results
  end

  # Create the object in the triple store.
  #
  # @param identifier [string] The identifer being checked.
  # @param version [integer] The version.
  # @param ra [object] The registration authority
  # @return [object] The created object.
  def self.create(identifier, version, ra)   
    object = IsoRegistrationState.from_data(identifier, version, ra)
    if object.valid?
      if !object.exists?  
        update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
          "INSERT DATA \n" +
          "{ \n" +
          "	:#{object.id} rdf:type isoR:RegistrationState . \n" +
          "	:#{object.id} isoR:byAuthority :#{object.registrationAuthority.id} . \n" +
          "	:#{object.id} isoR:registrationStatus \"#{object.registrationStatus}\"^^xsd:string . \n" +
          "	:#{object.id} isoR:administrativeNote \"#{object.administrativeNote}\"^^xsd:string . \n" +
          "	:#{object.id} isoR:effectiveDate \"#{object.effective_date}\"^^xsd:string . \n" +
          " :#{object.id} isoR:untilDate \"#{object.until_date}\"^^xsd:string . \n" +
          "	:#{object.id} isoR:unresolvedIssue \"#{object.unresolvedIssue}\"^^xsd:string . \n" +
          "	:#{object.id} isoR:administrativeStatus \"#{object.administrativeStatus}\"^^xsd:string . \n" +
          "	:#{object.id} isoR:previousState \"#{object.previousState}\"^^xsd:string . \n" +
          "}"
        response = CRUD.update(update)
        if !response.success?
          ConsoleLogger.info(C_CLASS_NAME,"create", "Failed to create object.")
          raise Exceptions::CreateError.new(message: "Failed to create " + C_CLASS_NAME + " object.")
        end
      else
        object.errors.add(:base, "The registration state is already in use.")
      end
    end
    return object    
  end

  # Get a set of counts for each registration state
  #
  # @return [Hash] Hash keyed by state containing the count
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

  # Update the object in the triple store.
  #
  # @param [Hash] params the required parameters
  # @option param [String] :registrationStatus The registration status
  # @option param [String] :previousState The previousState
  # @option param [String] :administrativeNote An admin note
  # @option param [String] :unresolvedIssue Any unresolved issues
  # @option param [String] :effectiveDate The effective date
  # @return [void]
  def update(params)  
    self.registrationStatus = params[:registrationStatus]
    self.previousState  = params[:previousState]
    self.administrativeNote = params[:administrativeNote]
    self.unresolvedIssue = params[:unresolvedIssue]
    if valid?
      update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
        "DELETE \n" +
        "{ \n" +
        " :" + id + " isoR:registrationStatus ?a . \n" +
        " :" + id + " isoR:administrativeNote ?b . \n" +
        " :" + id + " isoR:unresolvedIssue ?d . \n" +
        " :" + id + " isoR:previousState ?e . \n" +
        "} \n" +
        "INSERT \n" +
        "{ \n" +
        " :" + id + " isoR:registrationStatus \"#{self.registrationStatus}\"^^xsd:string . \n" +
        " :" + id + " isoR:administrativeNote \"#{self.administrativeNote}\"^^xsd:string . \n" +
        " :" + id + " isoR:unresolvedIssue \"#{self.unresolvedIssue}\"^^xsd:string . \n" +
        " :" + id + " isoR:previousState \"#{self.previousState}\"^^xsd:string . \n" +
        "} \n" +
        "WHERE \n" +
        "{ \n" +
        " :" + id + " isoR:registrationStatus ?a . \n" +
        " :" + id + " isoR:administrativeNote ?b . \n" +
        " :" + id + " isoR:unresolvedIssue ?d . \n" +
        " :" + id + " isoR:previousState ?e . \n" +
        "}"
      # Send the request, wait the resonse
      response = CRUD.update(update)
      # Response
      if !response.success?
        ConsoleLogger.info(C_CLASS_NAME, "update", "Failed to update object.")
        raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
      end
    end
  end
  
  # Create the object in the triple store.
  #
  def self.make_current(id)  
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + id + " isoR:effectiveDate ?a . \n" +
      " :" + id + " isoR:untilDate ?b . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " :" + id + " isoR:effectiveDate \"" + Time.now.iso8601 + "\"^^xsd:dateTime . \n" +
      " :" + id + " isoR:untilDate \"" + C_UNTIL_DATETIME + "\"^^xsd:dateTime . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + id + " isoR:effectiveDate ?a . \n" +
      " :" + id + " isoR:untilDate ?b . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME, "make_current", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Create the object in the triple store.
  #
  def self.make_not_current(id)  
    update = UriManagement.buildPrefix(C_NS_PREFIX, ["isoB", "isoR"]) +
      "DELETE \n" +
      "{ \n" +
      " :" + id + " isoR:untilDate ?a . \n" +
      "} \n" +
      "INSERT \n" +
      "{ \n" +
      " :" + id + " isoR:untilDate \"" + Time.now.iso8601 + "\"^^xsd:dateTime . \n" +
      "} \n" +
      "WHERE \n" +
      "{ \n" +
      " :" + id + " isoR:untilDate ?a . \n" +
      "}"
    # Send the request, wait the resonse
    response = CRUD.update(update)
    # Response
    if !response.success?
      ConsoleLogger.info(C_CLASS_NAME, "make_not_current", "Failed to update object.")
      raise Exceptions::UpdateError.new(message: "Failed to update " + C_CLASS_NAME + " object.")
    end
  end

  # Create the object from data. Will build the id for the object.
  #
  # @param identifier [string] The identifer of the item.
  # @param version [integer] The version of the item.
  # @param ra [object] The registration authority
  # @return [object] The created object.
  def self.from_data(identifier, version, ra)
    uri = UriV2.new({:namespace => @@base_namespace, :prefix => C_CID_PREFIX, :org_name => ra.namespace.shortName, :identifier => identifier, :version => version})
    object = self.new
    object.id = uri.id
    object.registrationStatus = C_INCOMPLETE
    object.administrativeNote = ""
    #object.effective_date = Time.parse(C_DEFAULT_DATETIME)
    #object.until_date = Time.parse(C_DEFAULT_DATETIME)
    object.unresolvedIssue = ""
    object.administrativeStatus = ""
    object.previousState  = C_INCOMPLETE 
    object.registrationAuthority = ra
    return object
  end

  # Create the object from JSON
  #
  # @param [hash] The JSON hash object
  # @return [object] The scoped identifier object
  def self.from_json(json)
    object = self.new
    object.id = json[:id]
    object.registrationAuthority = IsoRegistrationAuthority.from_json(json[:registration_authority])
    object.registrationStatus = json[:registration_status]
    object.administrativeNote = json[:administrative_note]
    object.effective_date = json[:effective_date].to_time_with_default
    object.until_date = json[:until_date].to_time_with_default
    object.current = json[:current]
    object.unresolvedIssue = json[:unresolved_issue]
    object.administrativeStatus = json[:administrative_status]
    object.previousState = json[:previous_state]
    return object
  end

  # Return the object as JSON
  #
  # @return [hash] The JSON hash.
  def to_json
    result = 
    { 
      :namespace => C_INSTANCE_NS, 
      :id => self.id, 
      :registration_authority => self.registrationAuthority.to_json,
      :registration_status => self.registrationStatus,
      :administrative_note => self.administrativeNote,
      :effective_date => "#{self.effective_date.iso8601}",
      :until_date => "#{self.until_date.iso8601}",
      :current => self.current,  
      :unresolved_issue => self.unresolvedIssue,
      :administrative_status => self.administrativeStatus,
      :previous_state => self.previousState 
    }
    return result
  end

  # Return the object as SPARQL
  #
  # @param sparql [object] The sparql object being built (to be added to)
  # @return [object] The URI of the object
  def to_sparql_v2(sparql)
    subject_uri = UriV2.new({id: self.id, namespace: @@base_namespace})
    subject = {uri: subject_uri}
    sparql.triple(subject, {:prefix => UriManagement::C_RDF, :id => "type"}, {:prefix => UriManagement::C_ISO_R, :id => "RegistrationState"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "byAuthority"}, {:prefix => C_NS_PREFIX, :id => self.registrationAuthority.id})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "registrationStatus"}, {:literal => "#{self.registrationStatus}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "administrativeNote"}, {:literal => "#{self.administrativeNote}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "effectiveDate"}, {:literal => "#{self.effective_date.iso8601}", :primitive_type => "dateTime"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "untilDate"}, {:literal => "#{self.until_date.iso8601}", :primitive_type => "dateTime"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "unresolvedIssue"}, {:literal => "#{self.unresolvedIssue}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "administrativeStatus"}, {:literal => "#{self.administrativeStatus}", :primitive_type => "string"})
    sparql.triple(subject, {:prefix => UriManagement::C_ISO_R, :id => "previousState"}, {:literal => "#{self.previousState}", :primitive_type => "string"})
    return subject_uri
  end

  # Object Valid
  #
  # @return [boolean] True if valid, false otherwise.
  def valid?
    ra_valid = self.registrationAuthority.valid?
    if !ra_valid
      self.registrationAuthority.errors.full_messages.each do |msg|
        self.errors[:base] << "Registration authority error: #{msg}"
      end
    end
    result = ra_valid &&
      valid_registration_state?(:registrationStatus, self.registrationStatus) && 
      valid_registration_state?(:previousState, self.previousState) && 
      FieldValidation.valid_label?(:administrativeNote, self.administrativeNote, self) &&
      FieldValidation.valid_label?(:unresolvedIssue, self.unresolvedIssue, self) &&
      FieldValidation.valid_label?(:administrativeStatus, self.administrativeStatus, self) 
    return result
  end

private

  def valid_registration_state?(field, value)
    return true if @@stateInfo.has_key?(value)
    self.errors.add(field, "is invalid")
    return false  
  end

end