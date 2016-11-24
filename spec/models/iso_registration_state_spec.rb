require 'rails_helper'

describe IsoRegistrationState do
  
  include DataHelpers

  it "clears triple store and loads test data" do
    clear_triple_store
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_scoped_identifier.ttl")
  end

  it "validates a valid object" do
    object = IsoRegistrationState.new
    object.registrationAuthority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.registrationStatus = "Incomplete"
    object.administrativeNote = "Note"
    object.effective_date = Time.now
    object.until_date = Time.now
    object.unresolvedIssue = "Unresolved issue"
    object.administrativeStatus = "Administrative status"
    object.previousState  = "Standard"
    expect(object.valid?).to eq(true)
  end

  it "does not validate an invalid object, Registration Status" do
    object = IsoRegistrationState.new
    object.registrationAuthority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.registrationStatus = "IncompleteXXX"
    object.administrativeNote = "Note"
    object.effective_date = Time.now
    object.until_date = Time.now
    object.unresolvedIssue = "Unresolved issue"
    object.administrativeStatus = "Administrative status"
    object.previousState  = "Standard"
    expect(object.valid?).to eq(false)
  end

  it "does not validate an invalid object, RA" do
    object = IsoRegistrationState.new
    object.registrationAuthority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.registrationAuthority.scheme = "DUS"
    object.registrationStatus = "Incomplete"
    object.administrativeNote = "Note"
    object.effective_date = "XXX"
    object.until_date = Time.now
    object.unresolvedIssue = "Unresolved issue"
    object.administrativeStatus = "Administrative status"
    object.previousState  = "Standard"
    expect(object.valid?).to eq(false)
  end

  it "does not validate an invalid object, previous state" do
    object = IsoRegistrationState.new
    object.registrationAuthority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.registrationStatus = "Incomplete"
    object.administrativeNote = "Note"
    object.effective_date = Time.now
    object.until_date = Time.now
    object.unresolvedIssue = "Unresolved issue"
    object.administrativeStatus = "Administrative status"
    object.previousState  = "StandardXXX"
    expect(object.valid?).to eq(false)
  end

  it "allows object to be initialized from triples" do
    result = 
      {
        :id=>"RS-ACME_TEST-1", 
        :namespace => "http://www.assero.co.uk/MDRItems",
        :administrative_note => "",
        :administrative_status => "",
        :previous_state => "Incomplete",
        :registration_status => "Incomplete",
        :unresolved_issue => "",
        :effective_date => "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false,
        :registration_authority => 
          {
            :id=>"RA-123456789", 
            :number=>"123456789", 
            :scheme=>"DUNS", 
            :owner=>true, 
            :namespace=>
              {
                :namespace=>"http://www.assero.co.uk/MDRItems", 
                :id=>"NS-BBB", 
                :name=>"BBB Pharma", 
                :shortName=>"BBB"
              }
          }
      }
    triples =[
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Registration#RegistrationState"},
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#byAuthority", object: "http://www.assero.co.uk/MDRItems#RA-123456789"},
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#registrationStatus", object: "Incomplete" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#effectiveDate", object:"2016-01-01T00:00:00+00:00" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#untilDate", object:"2016-01-01T00:00:00+00:00" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#administrativeNote", object:"" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#unresolvedIssue", object:"" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#administrativeStatus", object:"" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#previousState", object:"Incomplete" }
    ]
    expect(IsoRegistrationState.new(triples).to_json).to eq(result)    
  end

  it "allows object to be initialized from triples - error effective date" do
    result = 
      {
        :id=>"RS-ACME_TEST-1", 
        :namespace => "http://www.assero.co.uk/MDRItems",
        :administrative_note => "",
        :administrative_status => "",
        :previous_state => "Incomplete",
        :registration_status => "Incomplete",
        :unresolved_issue => "",
        :effective_date => "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false,
        :registration_authority => 
          {
            :id=>"RA-123456789", 
            :number=>"123456789", 
            :scheme=>"DUNS", 
            :owner=>true, 
            :namespace=>
              {
                :namespace=>"http://www.assero.co.uk/MDRItems", 
                :id=>"NS-BBB", 
                :name=>"BBB Pharma", 
                :shortName=>"BBB"
              }
          }
      }
    triples =[
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", object: "http://www.assero.co.uk/ISO11179Registration#RegistrationState"},
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#byAuthority", object: "http://www.assero.co.uk/MDRItems#RA-123456789"},
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#registrationStatus", object: "Incomplete" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#effectiveDate", object:"" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#untilDate", object:"2016-01-01T00:00:00+00:00" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#administrativeNote", object:"" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#unresolvedIssue", object:"" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#administrativeStatus", object:"" },
      { subject: "http://www.assero.co.uk/MDRItems#RS-ACME_TEST-1", predicate: "http://www.assero.co.uk/ISO11179Registration#previousState", object:"Incomplete" }
    ]
    expect(IsoRegistrationState.new(triples).to_json).to eq(result)    
  end

  it "detects registered state" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.registered?).to eq(true)
  end

  it "detects not registered state" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    result.registrationStatus = ""
    expect(result.registered?).to eq(false)
  end

  it "returns the no state status" do
    expect(IsoRegistrationState.no_state).to eq("")
  end

  it "allows the next state to be retrieved" do
    expect(IsoRegistrationState.nextState(IsoRegistrationState::C_CANDIDATE)).to eq(IsoRegistrationState::C_RECORDED)
  end
  
  it "allows the state label to be retrieved" do
    expect(IsoRegistrationState.stateLabel(IsoRegistrationState::C_RECORDED)).to eq("Recorded")
  end
  
  it "allows the state definition to be retrieved" do
    expect(IsoRegistrationState.stateDefinition(IsoRegistrationState::C_RECORDED)).to eq("The Registration Authority has confirmed that: a) all mandatory metadata attributes have been completed.")
  end
  
  it "allows the released state to be retrieved" do
    expect(IsoRegistrationState.releasedState).to eq(IsoRegistrationState::C_STANDARD)
  end
  
  it "allows the item to be checked for a release state" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.released_state?).to eq(true)
  end
  
  it "allows the item state to be checked for release state" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    result.registrationStatus = IsoRegistrationState::C_RECORDED
    expect(result.released_state?).to eq(false)
  end
  
  it "allows the edit state to be determined for an editable item" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.edit?).to eq(true)
  end
  
  it "allows the edit state to be determined for a locked item" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    result.registrationStatus = IsoRegistrationState::C_RETIRED
    expect(result.edit?).to eq(false)
  end
  
  it "allows the edit state to be determined for an editable item" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.delete?).to eq(false)
  end
  
  it "allows the edit state to be determined for a locked item" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    result.registrationStatus = IsoRegistrationState::C_INCOMPLETE
    expect(result.delete?).to eq(true)
  end
  
  it "allows the state after edit to be determined" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.state_on_edit).to eq(IsoRegistrationState::C_INCOMPLETE)
  end
  
  it "allows whether a new version is required after an edit to be determined" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.new_version?).to eq(true)
  end
  
  it "determines if the item can be current" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.can_be_current?).to eq(true)
  end
  
  it "determines if the item can be changed" do
    result = IsoRegistrationState.find("RS-TEST_1-1")
    expect(result.can_be_changed?).to eq(true)
  end

  it "checks if an item exists" do
    rs = IsoRegistrationState.find("RS-TEST_1-1")
    expect(rs.exists?).to eq(true)
  end

  it "checks if an item does not exist" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    rs = IsoRegistrationState.from_json(
      {
        :id=>"RS-TEST_1-1x", 
        :registration_authority => ra.to_json, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      })
    expect(rs.exists?).to eq(false)
  end

  it "finds a given id" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    result = IsoRegistrationState.from_json(
      {
        :id=>"RS-TEST_1-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      })
    expect(IsoRegistrationState.find("RS-TEST_1-1").to_json).to eq(result.to_json)
  end

  it "does not find an unknown id" do
    expect(IsoRegistrationState.find("RS-TEST_1-1x").id).to eq("")
  end

  # self.all
  it "allows all records to be returned" do
    results = Array.new
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    #ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    ra = IsoRegistrationAuthority.new
    results << IsoRegistrationState.from_json(
      {
        :id=>"RS-TEST_1-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      })
    results << IsoRegistrationState.from_json(
      {
        :id=>"RS-TEST_3-3", 
        :registration_authority => ra.to_json, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00", 
        :until_date => "2016-01-01T00:00:00+00:00", 
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      })
    results << IsoRegistrationState.from_json(
      {
        :id=>"RS-TEST_2-2", 
        :registration_authority => ra.to_json, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      })
    results << IsoRegistrationState.from_json(
      {
        :id=>"RS-TEST_3-5", 
        :registration_authority => ra.to_json, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      })
    results << IsoRegistrationState.from_json(
      {
        :id=>"RS-TEST_3-4", 
        :registration_authority => ra.to_json, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      })
    expect(IsoRegistrationState.all.to_json).to eq(results.to_json)
  end

  it "allows an object to be created" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    result = IsoRegistrationState.from_json(
      {
        :id =>"RS-BBB_NEW_1-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Incomplete",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Incomplete"
      })
    expect(IsoRegistrationState.create("NEW_1", 1, ra).to_json).to eq(result.to_json)
  end

  it "prevents a duplicate object being created" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    result = IsoRegistrationState.from_json(
      {
        :id =>"RS-BBB_NEW_1-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Incomplete",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Incomplete"
      })
    rs = IsoRegistrationState.create("NEW_1", 1, ra)
    expect(rs.errors.count).to eq(1)
    expect(rs.errors.full_messages.to_sentence).to eq("The registration state is already in use.")
  end

  it "prevents an invalid object being created" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    ra.number = "1234567890"
    result = IsoRegistrationState.from_json(
      {
        :id =>"RS-BBB_NEW2-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Incomplete",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Incomplete"
      })
     rs = IsoRegistrationState.create("NEW2", 1, ra)
    expect(rs.errors.count).to eq(1)
    expect(rs.errors.full_messages.to_sentence).to eq("Registration authority error: Number does not contains 9 digits")
  end

  it "provides a count of registration status" do
    result = 
      {
        IsoRegistrationState::C_STANDARD => "5",
        IsoRegistrationState::C_INCOMPLETE => "1"
      }
    expect(IsoRegistrationState.count.to_json).to eq(result.to_json)
  end

  it "allows for an object to be updated" do
    object = IsoRegistrationState.find("RS-TEST_3-4")
    object.update( 
      {
        registrationStatus: IsoRegistrationState::C_RETIRED, 
        previousState: IsoRegistrationState::C_STANDARD, 
        administrativeNote: "X1", 
        unresolvedIssue: "X2", 
        effectiveDate: "Wont Change" 
      })
    # Something here    
  end
  
  it "allows for an object to be made current" do
    object = IsoRegistrationState.find("RS-TEST_3-5")
    IsoRegistrationState.make_current(object.id)
  end
  
  it "allows for an object to be made not current" do
    object = IsoRegistrationState.find("RS-TEST_3-5")
    IsoRegistrationState.make_not_current(object.id)
  end
  
  # self.from_data(identifier, version, ra)
  it "allows an object to be created from data" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    result = IsoRegistrationState.from_json(
      {
        :id =>"RS-BBB_NEW_1-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Incomplete",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Incomplete"
      })
    expect(IsoRegistrationState.from_data("NEW_1", 1, ra).to_json).to eq(result.to_json)
  end
  
  # self.from_json(json)
  it "allows an object to be created from JSON" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    result = IsoRegistrationState.from_json(
      {
        :id =>"RS-BBB_NEW_1-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Incomplete",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Incomplete"
      })
    json = 
      {
        :id =>"RS-BBB_NEW_1-1", 
        :registration_authority => ra.to_json, 
        :registration_status => "Incomplete",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :current => false, 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Incomplete"
      }
    expect(IsoRegistrationState.from_json(json).to_json).to eq(result.to_json)
  end
  
  # to_json
  it "allows an object to be exported as JSON" do
    org = IsoNamespace.from_json({id: "NS-BBB", namespace: "http://www.assero.co.uk/MDRItems", name: "BBB Pharma", shortName: "BBB"})
    ra = IsoRegistrationAuthority.from_json({id: "RA-123456789", number: "123456789", scheme: "DUNS", owner: true, namespace: org.to_json})
    result = IsoRegistrationState.from_json(
      {
        :id =>"RS-TEST_3-4", 
        :registration_authority => ra.to_json, 
        :registration_status => "Retired",
        :administrative_note => "X1", 
        :effective_date => "2016-01-01T00:00:00+00:00", 
        :until_date => "2016-01-01T00:00:00+00:00", 
        :current => false, 
        :unresolved_issue => "X2", 
        :administrative_status => "", 
        :previous_state => "Standard"
      })
    expect(IsoRegistrationState.find("RS-TEST_3-4").to_json).to eq(result.to_json)
  end

  # to_sparql_v2(sparql, ra, identifier, version)
  it "allows an object to be exported as SPARQL" do
    sparql = SparqlUpdateV2.new
    result = 
      "PREFIX isoR: <http://www.assero.co.uk/ISO11179Registration#>\n" +
      "PREFIX mdrItems: <http://www.assero.co.uk/MDRItems#>\n" +
      "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>\n" +
      "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>\n" +
      "PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>\n" +
      "PREFIX skos: <http://www.w3.org/2004/02/skos/core#>\n" +
      "INSERT DATA \n" +
      "{ \n" + 
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> rdf:type isoR:RegistrationState . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:byAuthority mdrItems:RA-123456789 . \n" + 
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:registrationStatus \"Retired\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:administrativeNote \"X1\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:effectiveDate \"2016-01-01T00:00:00+00:00\"^^xsd:dateTime . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:untilDate \"2016-01-01T00:00:00+00:00\"^^xsd:dateTime . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:unresolvedIssue \"X2\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:administrativeStatus \"\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:previousState \"Standard\"^^xsd:string . \n" +
      "}"
    IsoRegistrationState.find("RS-TEST_3-4").to_sparql_v2(sparql)
    expect(sparql.to_s).to eq(result)
  end
  
  it "handles a bad response error - update" do
    object = IsoRegistrationState.find("RS-TEST_3-4")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{object.update( 
      {
        registrationStatus: IsoRegistrationState::C_RETIRED, 
        previousState: IsoRegistrationState::C_STANDARD, 
        administrativeNote: "X1", 
        unresolvedIssue: "X2", 
        effectiveDate: "Wont Change" 
      })}.to raise_error(Exceptions::UpdateError)
  end

  it "handles a bad response error - make_current" do
    object = IsoRegistrationState.find("RS-TEST_3-4")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{IsoRegistrationState.make_current(object.id)}.to raise_error(Exceptions::UpdateError)
  end

  it "handles a bad response error - make_not_current" do
    object = IsoRegistrationState.find("RS-TEST_3-4")
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{IsoRegistrationState.make_not_current(object.id)}.to raise_error(Exceptions::UpdateError)
  end

  it "clears triple store" do
    clear_triple_store
  end

end
  