require 'rails_helper'

describe IsoRegistrationStateV2 do
  
  include DataHelpers
  include PauseHelpers
  include SparqlHelpers

  def sub_dir
    return "models/iso_registration_state"
  end

  before :each do
    clear_triple_store
    load_schema_file_into_triple_store("ISO11179Identification.ttl")
    load_schema_file_into_triple_store("ISO11179Registration.ttl")
    load_test_file_into_triple_store("iso_namespace_fake.ttl")
    load_test_file_into_triple_store("iso_registration_authority_fake.ttl")
    load_test_file_into_triple_store("iso_scoped_identifier.ttl")
  end

 	it "check the state table" do
 		expected = %i(Not_Set Incomplete Candidate Recorded Qualified Standard Retired Superseded)
 		table = Rails.configuration.iso_registration_state
 		index = 0
  	table.each do |key, item|
  		expect(key).to eq(expected[index])
  		index += 1
  	end
 	end

  it "creates a new object" do
    object = IsoRegistrationStateV2.new
    expect(object.id).to be_nil
    expect(object.registration_status).to eq("Not_Set")
    expect(object.administrative_note).to eq("")
    expect(object.effective_date.to_s).to eq("2016-01-01 00:00:00 +0000")
    expect(object.until_date.to_s).to eq("2016-01-01 00:00:00 +0000")
    expect(object.unresolved_issue).to eq("")
    expect(object.administrative_status).to eq("")
    expect(object.previous_state).to eq("Not_Set")
  end

  it "validates a valid object" do
    object = IsoRegistrationStateV2.new
    object.by_authority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.registration_status = "Incomplete"
    object.administrative_note = "Note"
    object.effective_date = Time.now
    object.until_date = Time.now
    object.unresolved_issue = "Unresolved issue"
    object.administrative_status = "Administrative status"
    object.previous_state   = "Standard"
    object.uri = "na"
    expect(object.valid?).to eq(true)
  end

  it "does not validate an invalid object, Registration Status" do
    object = IsoRegistrationStateV2.new
    object.by_authority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.registration_status = "IncompleteXXX"
    object.administrative_note = "Note"
    object.effective_date = Time.now
    object.until_date = Time.now
    object.unresolved_issue = "Unresolved issue"
    object.administrative_status = "Administrative status"
    object.previous_state   = "Standard"
    object.uri = "na"
    expect(object.valid?).to eq(false)
  end

  it "does not validate an invalid object, RA" do
    object = IsoRegistrationStateV2.new
    object.by_authority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.by_authority.international_code_designator = "DUS"
    object.registration_status = "Incomplete"
    object.administrative_note = "Note"
    object.effective_date = "XXX"
    object.until_date = Time.now
    object.unresolved_issue = "Unresolved issue"
    object.administrative_status = "Administrative status"
    object.previous_state   = "Standard"
    object.uri = "na"
    expect(object.valid?).to eq(false)
  end

  it "does not validate an invalid object, previous state" do
    object = IsoRegistrationStateV2.new
    object.by_authority = IsoRegistrationAuthority.find_by_short_name("AAA")
    object.registration_status = "Incomplete"
    object.administrative_note = "Note"
    object.effective_date = Time.now
    object.until_date = Time.now
    object.unresolved_issue = "Unresolved issue"
    object.administrative_status = "Administrative status"
    object.previous_state   = "StandardXXX"
    object.uri = "na"
    expect(object.valid?).to eq(false)
  end

  it "detects registered state" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.registered?).to eq(true)
  end

  it "detects not registered state" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    result.registration_status = ""
    expect(result.registered?).to eq(false)
    result.registration_status = "Not_Set"
    expect(result.registered?).to eq(false)
  end

  it "returns the no state status" do
    expect(IsoRegistrationStateV2.no_state).to eq("Not_Set")
  end

  it "allows the next state to be retrieved" do
  	table = Rails.configuration.iso_registration_state
  	table.each do |key, item|
  		expected = item[:next_state]
	    expect(IsoRegistrationStateV2.next_state(key)).to eq(expected)
  	end
  end
  
  it "allows the state label to be retrieved" do
  	table = Rails.configuration.iso_registration_state
  	table.each do |key, item|
  		expected = item[:label]
	    expect(IsoRegistrationStateV2.state_label(key)).to eq(expected)
  	end
  end
  
  it "allows the state definition to be retrieved" do
  	table = Rails.configuration.iso_registration_state
  	table.each do |key, item|
  		expected = item[:definition]
	    expect(IsoRegistrationStateV2.state_definition(key)).to eq(expected)
  	end
  end
  
  it "allows the released state to be retrieved" do
    expect(IsoRegistrationStateV2.released_state).to eq("Standard")
  end
  
  it "allows the item to be checked for a release state" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.released_state?).to eq(true)
  end
  
  it "allows the item state to be checked for release state" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    result.registration_status = "Recorded"
    expect(result.released_state?).to eq(false)
  end
  
  it "allows the item state to be checked for has been in release state, superceeded" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    result.registration_status = "Superseded"
    expect(result.has_been_released_state?).to eq(true)
  end
  
  it "allows the item state to be checked for has been in release state, retired" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    result.registration_status = "Retired"
    expect(result.has_been_released_state?).to eq(true)
  end
  
  it "allows the item state to be checked for has been in release state, standard" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    result.registration_status = "Standard"
    expect(result.has_been_released_state?).to eq(false)
  end
  
  it "allows the edit state to be determined for an editable item" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.edit?).to eq(true)
  end
  
  it "allows the edit state to be determined for a locked item" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    result.registration_status = "Retired"
    expect(result.edit?).to eq(false)
  end
  
  it "allows the edit state to be determined for an editable item" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.delete?).to eq(false)
  end
  
  it "allows the edit state to be determined for a locked item" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    result.registration_status = "Incomplete"
    expect(result.delete?).to eq(true)
  end
  
  it "allows the state after edit to be determined" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.state_on_edit).to eq("Incomplete")
  end
  
  it "allows whether a new version is required after an edit to be determined" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.new_version?).to eq(true)
  end
  
  it "determines if the item can be current" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.can_be_current?).to eq(true)
  end
  
  it "determines if the item can be changed" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    result = IsoRegistrationStateV2.find(uri)
    expect(result.can_be_changed?).to eq(true)
  end

  it "finds a given id" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1")
    expected = 
    {
      :uri=>"http://www.assero.co.uk/MDRItems#RS-TEST_1-1", 
      :by_authority => "http://www.assero.co.uk/RA#DUNS123456789", 
      :registration_status => "Standard",
      :administrative_note => "", 
      :effective_date=> "2016-01-01T00:00:00+00:00",
      :until_date => "2016-01-01T00:00:00+00:00",
      :unresolved_issue => "", 
      :administrative_status => "", 
      :previous_state => "Qualified"
    }
    result = IsoRegistrationStateV2.find(uri)
    expect(result.to_h).to eq(expected)
  end

  it "does not find an unknown id" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_1-1x")
    expect{IsoRegistrationStateV2.find(uri)}.to raise_error
  end

  it "allows all records to be returned" do
    org = IsoNamespace.find_by_short_name("BBB")
    ra = IsoRegistrationAuthority.find(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    expected = 
    [
      {
        :uri=>"http://www.assero.co.uk/MDRItems#RS-TEST_1-1", 
        :by_authority => ra.uri.to_s, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      },
      {
        :uri=>"http://www.assero.co.uk/MDRItems#RS-TEST_3-3", 
        :by_authority => ra.uri.to_s, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00", 
        :until_date => "2016-01-01T00:00:00+00:00", 
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      },
      {
        :uri=>"http://www.assero.co.uk/MDRItems#RS-TEST_2-2", 
        :by_authority => ra.uri.to_s, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      },
      {
        :uri=>"http://www.assero.co.uk/MDRItems#RS-TEST_3-5", 
        :by_authority => ra.uri.to_s, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      },
      {
        :uri=>"http://www.assero.co.uk/MDRItems#RS-TEST_3-4", 
        :by_authority => ra.uri.to_s, 
        :registration_status => "Standard",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Qualified"
      },
      {
        :uri => "http://www.assero.co.uk/MDRItems#RS-TEST_SV1-5",
        :by_authority => ra.uri.to_s, 
        :registration_status => "Standard",
        :administrative_note => "",
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :unresolved_issue => "",
        :administrative_status => "",
        :previous_state => "Qualified"
      },
      {
        :uri => "http://www.assero.co.uk/MDRItems#RS-TEST_SV2-5",
        :by_authority => ra.uri.to_s, 
        :registration_status => "Standard",
        :administrative_note => "",
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :unresolved_issue => "",
        :administrative_status => "",
        :previous_state => "Qualified"
      }
    ]
    results = IsoRegistrationStateV2.all
    expect(results.count).to eq(7)
    results.each do |result|
      compare = expected.find{|x| x[:uri] == result.uri.to_s}
      expect(result.to_h).to eq(compare)
    end
  end

  it "allows an object to be created" do
    org = IsoNamespace.find_by_short_name("BBB")
    ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    expected = 
      {
        :uri => "http://www.assero.co.uk/RS/BBB/NEW",
        :by_authority => ra.to_h, 
        :registration_status => "Incomplete",
        :administrative_note => "", 
        :effective_date=> "2016-01-01T00:00:00+00:00",
        :until_date => "2016-01-01T00:00:00+00:00",
        :unresolved_issue => "", 
        :administrative_status => "", 
        :previous_state => "Incomplete"
      }
    result = IsoRegistrationStateV2.create(identifier: "NEW", registration_status: "Incomplete", previous_state: "Incomplete", by_authority: ra)
    expect(result.to_h).to eq(expected)
  end

  it "prevents an invalid object being created" do
    org = IsoNamespace.find_by_short_name("BBB")
    ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    ra.organization_identifier = "1234567890"
    rs = IsoRegistrationStateV2.create(identifier: "NEW 2", by_authority: ra)
    expect(rs.errors.count).to eq(1)
    expect(rs.errors.full_messages.to_sentence).to eq("Registration authority error: Organization identifier is invalid")
  end

  it "provides a count of registration status" do
    result = 
      {
        "Standard" => "7",
        "Incomplete" => "1"
      }
    expect(IsoRegistrationStateV2.count.to_json).to eq(result.to_json)
  end

  it "allows for an object to be updated" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-4")
    object = IsoRegistrationStateV2.find(uri)
    object.administrative_note = "X1"
    object.update
    object = IsoRegistrationStateV2.find(uri)
    expect(object.administrative_note).to eq("X1")
  end
  
  it "allows for an object to be updated, effective date unchanged"

  it "prevents an object to be updated if invalid admin note" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-4")
    object = IsoRegistrationStateV2.find(uri)
    expect(object.administrative_note).to eq("")
    object.administrative_note = "£±£±"
    expect(object.valid?).to eq(false)
    object.update
    object = IsoRegistrationStateV2.find(uri)
    expect(object.administrative_note).to eq("")
  end
  
  it "prevents an object to be updated if invalid unresolved issue" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-4")
    object = IsoRegistrationStateV2.find(uri)
    expect(object.unresolved_issue).to eq("")
    object.unresolved_issue = "£±£±"
    expect(object.valid?).to eq(false)
    object.update
    object = IsoRegistrationStateV2.find(uri)
    expect(object.unresolved_issue).to eq("")
  end
  
  it "prevents an object to be updated if invalid state"
    
  it "allows for an object to be made current" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-5")
    object = IsoRegistrationStateV2.find(uri)
    object.make_current
    object = IsoRegistrationStateV2.find(uri)
    expect(object.current?).to eq(true)
  end
  
  it "allows for an object to be made not current" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-5")
    object = IsoRegistrationStateV2.find(uri)
    object.make_not_current
    object = IsoRegistrationStateV2.find(uri)
    expect(object.current?).to eq(false)
  end
  
  it "allows an object to be created from JSON" do
    ra = IsoRegistrationAuthority.find_children(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    input = 
    {
      :identifier =>"NEW 1", 
      :by_authority => ra.to_h, 
      :registration_status => "Incomplete",
      :administrative_note => "", 
      :effective_date=> "2016-01-01T00:00:00+00:00",
      :until_date => "2016-01-01T00:00:00+00:00",
      :unresolved_issue => "", 
      :administrative_status => "", 
      :previous_state => "Incomplete"
    }
    expected = input.except(:identifier)
    expected[:uri] = {} # Will be empty until saved.
    expect(IsoRegistrationStateV2.from_h(input).to_h).to eq(expected)
  end
  
  it "allows an object to be output as JSON" do
    ra = IsoRegistrationAuthority.find(Uri.new(uri: "http://www.assero.co.uk/RA#DUNS123456789"))
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-5")
    object = IsoRegistrationStateV2.find_children(uri)
    expected = 
    {
      :uri=>"http://www.assero.co.uk/MDRItems#RS-TEST_3-5", 
      :by_authority => ra.to_h, 
      :registration_status => "Standard",
      :administrative_note => "", 
      :effective_date=> "2016-01-01T00:00:00+00:00",
      :until_date => "2016-01-01T00:00:00+00:00",
      :unresolved_issue => "", 
      :administrative_status => "", 
      :previous_state => "Qualified"
    }
    expect(object.to_h).to eq(expected)
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
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:registration_status \"Retired\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:administrative_note \"X1\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:effectiveDate \"2016-01-01T00:00:00%2B00:00\"^^xsd:dateTime . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:untilDate \"2016-01-01T00:00:00%2B00:00\"^^xsd:dateTime . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:unresolved_issue \"X2\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:administrative_status \"\"^^xsd:string . \n" +
      "<http://www.assero.co.uk/MDRItems#RS-TEST_3-4> isoR:previous_state  \"Standard\"^^xsd:string . \n" +
      "}"
  #Xwrite_text_file_2(result, sub_dir, "to_sparql_expected.txt")
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-4")
    object = IsoRegistrationStateV2.find(uri)
    object.to_sparql_v2(sparql)
    #expect(sparql.to_s).to eq(result)
    check_sparql_no_file(sparql.to_s, "to_sparql_expected.txt")
  end
  
  it "handles a bad response error - make_current" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-4")
    object = IsoRegistrationStateV2.find(uri)
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{object.make_current}.to raise_error(Errors::UpdateError, "Failed to update an item in the database. SPARQL update failed.")
  end

  it "handles a bad response error - make_not_current" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-4")
    object = IsoRegistrationStateV2.find(uri)
    response = Typhoeus::Response.new(code: 200, body: "")
    expect(Rest).to receive(:sendRequest).and_return(response)
    expect(response).to receive(:success?).and_return(false)
    expect{object.make_not_current}.to raise_error(Errors::UpdateError, "Failed to update an item in the database. SPARQL update failed.")
  end

  it "checks current status" do
    uri = Uri.new(uri: "http://www.assero.co.uk/MDRItems#RS-TEST_3-4")
    object = IsoRegistrationStateV2.find(uri)
    expect(object.current?).to eq(false)
    object.make_current
    object = IsoRegistrationStateV2.find(uri)
    expect(object.current?).to eq(true)
    object.make_not_current
    object = IsoRegistrationStateV2.find(uri)
    expect(object.current?).to eq(false)
  end

end
  